variable "module_depends_on" {
  default = []
}

variable "vpc_id" {
  type        = string
  description = "VPC id"
}

variable "subnets" {
  type        = list
  description = "vpc subnets"
}

variable "environment" {
  type        = string
  description = "Environment Use in tags and annotations for identify EKS cluster"
  default     = "test"
}

variable "project" {
  type        = string
  description = "Project Use in tags and annotations for identify EKS cluster"
  default     = "EDUCATION"
}

variable "cluster_name" {
  description = "Name of cluster"
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
  description = "Major Database enjine version"
  default     = "9"
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