
data "aws_subnet_ids" "all" {
  vpc_id = var.vpc_id
}

resource "aws_security_group" "eks_workers" {
  name        = "${var.cluster_name}-rds-access-from-eks"
  description = "Allow EKS workers access to RDS databases"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.worker_security_group_id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "tcp"
    security_groups = [var.worker_security_group_id]
  }
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
  version = "2.20"

  identifier = var.rds_instance_name

  engine               = var.rds_database_engine
  engine_version       = var.rds_database_engine_version
  major_engine_version = var.rds_database_major_engine_version
  instance_class       = var.rds_database_instance
  allocated_storage    = var.rds_allocated_storage
  storage_encrypted    = var.rds_storage_encrypted

  kms_key_id = var.rds_kms_key_id
  name       = var.rds_database_name
  multi_az   = var.rds_database_multi_az

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  username = var.rds_database_username
  password = var.rds_database_password != "" ? var.rds_database_password : random_password.rds_password.result
  port     = lookup(var.rds_port_mapping, var.rds_database_engine)

  vpc_security_group_ids = [aws_security_group.eks_workers.id]

  maintenance_window = var.rds_maintenance_window
  backup_window      = var.rds_backup_window

  # disable backups to create DB faster
  backup_retention_period = 0

  tags = merge(
    var.rds_database_tags,
    {
      Project     = var.project
      Environment = var.environment
    },
  )

  enabled_cloudwatch_logs_exports = var.rds_enabled_cloudwatch_logs_exports

  # DB subnet group
  subnet_ids = var.subnets

  # DB parameter group
  family = "${var.rds_database_engine}${var.rds_database_major_engine_version}"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = var.rds_instance_name

  # Database Deletion Protection
  deletion_protection = var.rds_database_delete_protection

  # Publicly accessible
  publicly_accessible = var.rds_publicly_accessible

  # For snapshot_identifier to be null
  snapshot_identifier = null

}