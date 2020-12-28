# For depends_on queqe
variable "module_depends_on" {
  default     = []
  type        = list(any)
  description = "A list of explicit dependencies"
}

variable "cluster_name" {
  type        = string
  default     = "null"
  description = "A name of the Amazon EKS cluster"
}

variable "domains" {
  type        = list(string)
  default     = []
  description = "A list of domains to use for ingresses"
}

variable "config_path" {
  description = "location of the kubeconfig file"
  default     = "~/.kube/config"
}

variable "airflow_fernetKey" {
  description = "https://bcb.github.io/airflow/fernet-key"
  default     = "GFqrDfu-0oac6x2ATKLsx-Mr2yHKWFpa5hY4pYeWmXw="
}

variable "airflow_username" {
  default     = ""
  description = "Username for auth"
}

variable "airflow_password" {
  default     = ""
  description = "Password for auth"
}

variable "airflow_postgresql_local" {
  default     = true
  description = "Internal database or external"
}

variable "airflow_postgresql_host" {
  default     = ""
  description = "external Postgresql host"
}

variable "airflow_postgresql_port" {
  default     = "5432"
  description = "external Postgresql port"
}

variable "airflow_postgresql_username" {
  default     = "postgresqluser"
  description = "external Postgresql username"
}

variable "airflow_postgresql_password" {
  default     = ""
  description = "external Postgresql password"
}

variable "airflow_postgresql_database" {
  default     = "airflow"
  description = "external Postgresql database"
}

variable "airflow_redis_local" {
  default     = "true"
  description = "internal redis or external"
}

variable "airflow_redis_host" {
  default     = ""
  description = "external redis host"
}

variable "airflow_redis_port" {
  default     = "6379"
  description = "external redis port"
}

variable "airflow_redis_username" {
  default     = "redisuser"
  description = "redis username"
}

variable "airflow_redis_password" {
  default     = ""
  description = "redis password"
}
