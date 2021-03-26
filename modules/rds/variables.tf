variable "module_depends_on" {
  default     = []
  type        = list(any)
  description = "A list of explicit dependencies"
}

variable "vpc_id" {
  type        = string
  default     = null
  description = "An ID of the existing AWS VPC"
}

variable "subnets" {
  type        = list(any)
  description = "vpc subnets"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "A value that will be used in annotations and tags to identify resources with the `Environment` key"
}

variable "project" {
  type        = string
  default     = "EDUCATION"
  description = "A value that will be used in annotations and tags to identify resources with the `Project` key"
}

variable "cluster_name" {
  type        = string
  default     = null
  description = "A name of the Amazon EKS cluster"
}

variable "config_path" {
  description = "location of the kubeconfig file"
  default     = "~/.kube/config"
}

variable "rds_database_name" {
  type        = string
  description = "Database name"
  default     = "exampledb"
}

variable "rds_database_multi_az" {
  type        = bool
  description = "Enabled multi_az for RDS"
  default     = "true"
}

variable "rds_database_engine" {
  type        = string
  description = "What server use? postgres | mysql | oracle-ee | sqlserver-ex"
  default     = "postgres"
}

variable "rds_database_engine_version" {
  type        = string
  description = "Engine version"
  default     = "9.6.9"
}

variable "rds_database_major_engine_version" {
  type        = string
  description = "Major Database engine version"
}

variable "rds_database_instance" {
  type        = string
  description = "RDS instance type"
  default     = "db.t3.large"
}

variable "rds_database_username" {
  type        = string
  description = "Database username"
  default     = "exampleuser"
}

variable "rds_database_password" {
  type        = string
  description = "Database password"
  default     = ""
}

variable "rds_kms_key_id" {
  type        = string
  description = "Id of kms key for encrypt database"
  default     = ""
}

variable "rds_allocated_storage" {
  type        = string
  description = "Database storage in GB"
  default     = "10"
}

variable "rds_storage_encrypted" {
  type        = string
  description = "Database must be encrypted?"
  default     = "false"
}

variable "rds_maintenance_window" {
  type        = string
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'"
  default     = "Mon:00:00-Mon:03:00"
}

variable "rds_backup_window" {
  type        = string
  description = ""
  default     = "03:00-06:00"
}

variable "rds_port_mapping" {
  description = "mapping port for engine type"
  default = {
    "postgres"     = "5432",
    "sqlserver-ex" = "1433",
    "mysql"        = "3306",
    "oracle-ee"    = "1521"
  }
}

variable "rds_database_delete_protection" {
  type        = bool
  description = "enabled delete protection for database"
  default     = "false"
}

variable "rds_database_tags" {
  default     = {}
  description = "Additional tags for rds instance"
  type        = map(string)
}



variable "rds_iam_database_authentication_enabled" {
  default     = false
  description = "Set to true to authenticate to RDS using an IAM role"
  type        = bool
}


variable "rds_enabled_cloudwatch_logs_exports" {
  default     = []
  description = "List of cloudwatch log types to enable"
  type        = list(string)
}
variable "rds_instance_name" {
  description = "Name of the RDS instance"
  type        = string
}


variable "rds_publicly_accessible" {
  description = "Set to true to enable accessing the RDS DB from outside the VPC"
  default     = false
  type        = bool
}


variable "worker_security_group_id" {
  description = "ID of the EKS workers' security group"
  type        = string

}

