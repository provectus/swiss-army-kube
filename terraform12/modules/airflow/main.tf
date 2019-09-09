#######
variable "environment" {}
variable "cluster_name" {}
variable "vpc_id" {}

data "aws_subnet_ids" "all" {
  vpc_id = var.vpc_id
}

data "aws_security_group" "default" {
  vpc_id = var.vpc_id
  name   = "default"
}


module "pgsql_server_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/postgresql"
  version = "~> 3.0"

  name        = "${var.cluster_name}-pgsql"
  description = "Security group for PostgreSQL"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["10.0.0.0/8"]
}

provider "random" {
  version = "~> 2.1"
}

resource "random_string" "dbpassword" {
  length = 16
  special = false
}

variable "db_backup_retention" {}
variable "instance_class" {}
variable "allocated_storage" {}

module "postgres" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = "${var.cluster_name}db"

  engine            = "postgres"
  engine_version    = "11.4"
  instance_class    = "${var.instance_class}"
  allocated_storage = "${var.allocated_storage}"
  storage_encrypted = false

  # kms_key_id        = "arm:aws:kms:<region>:<account id>:key/<kms key id>"
  name = "${replace(var.cluster_name, "-", "")}db"

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  username = "airflow"

  password = "${random_string.dbpassword.result}"
  port     = "5432"

  vpc_security_group_ids = ["${module.pgsql_server_sg.this_security_group_id}"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # disable backups to create DB faster
  backup_retention_period = "${var.db_backup_retention}"

  tags = {
    Environment = "${var.environment}"
  }

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # DB subnet group
  subnet_ids = "${data.aws_subnet_ids.all.ids}"

  # DB parameter group
  family = "postgres11"

  # DB option group
  major_engine_version = "11.4"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "${var.cluster_name}db"

  # Database Deletion Protection
  deletion_protection = true
}

# resource "kubernetes_namespace" "airflow" {
#   metadata {
#     name = "airflow"
#   }
# }

resource "kubernetes_secret" "airflow-secrets" {
  # depends_on = ["kubernetes_namespace.airflow"]

  metadata {
    name = "airflow-secrets"
    namespace = "airflow"
  }

  data = {
    sql_alchemy_conn = "postgresql+psycopg2://${module.postgres.this_db_instance_username}:${module.postgres.this_db_instance_password}@${module.postgres.this_db_instance_address}:5432/${module.postgres.this_db_instance_name}"
    postgres_user = "${module.postgres.this_db_instance_username}"
    postgres_password = "${module.postgres.this_db_instance_password}"
    postgres_host = "${module.postgres.this_db_instance_address}"
    postgres_port = "${module.postgres.this_db_instance_port}"
    postgres_db = "${module.postgres.this_db_instance_name}"
  }

  type = "Opaque"
}



### Airflow S3 bucket for keeping logs from workers
resource "aws_s3_bucket" "airflow-logs" {
  bucket = "${var.cluster_name}-airflow-logs"
  acl    = "private"

  tags = {
    Name        = "${var.cluster_name}-airflow-logs"
    Environment = "${var.environment}"
    Team        = "DevOps"
    Description = "Airflow workers logs"
  }
}
