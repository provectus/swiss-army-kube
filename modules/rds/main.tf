data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = var.vpc_id
}

data "aws_security_group" "default" {
  vpc_id = var.vpc_id
  name   = "default"
}

resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "!#%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "rds_password" {
  name  = "/rds-${var.rds_database_name}/${var.cluster_name}/${var.rds_database_username}"
  type  = "SecureString"
  value = var.rds_database_password != "" ? var.rds_database_password : random_password.rds_password.result
}

module "db" {

  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = var.rds_database_name

  engine            = var.rds_database_engine
  engine_version    = var.rds_database_engine_version
  instance_class    = var.rds_database_instance
  allocated_storage = var.rds_allocated_storage
  storage_encrypted = var.rds_storage_encrypted

  kms_key_id = var.rds_kms_key_id
  name       = var.rds_database_name
  multi_az   = var.rds_database_multi_az

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  username = var.rds_database_username
  password = var.rds_database_password != "" ? var.rds_database_password : random_password.rds_password.result
  port     = "${lookup(var.rds_port_mapping, var.rds_database_engine)}"

  vpc_security_group_ids = [data.aws_security_group.default.id]

  maintenance_window = var.rds_maintenance_window
  backup_window      = var.rds_backup_window

  # disable backups to create DB faster
  backup_retention_period = 0

  tags = merge(
    var.rds_database_tags,
    {
      Owner       = var.project
      Environment = var.environment
    },
  )

  enabled_cloudwatch_logs_exports = var.rds_database_engine == "postgresql" ? ["postgresql", "upgrade"] : ["alert", "audit", "error", "general", "listener", "slowquery"]

  # DB subnet group
  subnet_ids = var.subnets

  # DB parameter group
  family = var.rds_database_engine == "postgresql" ? "postgres9.6" : ""

  # Snapshot name upon DB deletion
  final_snapshot_identifier = var.rds_database_name

  # Database Deletion Protection
  deletion_protection = var.rds_database_delete_protection
}