# For depends_on queqe
variable module_depends_on {
  default     = []
  type        = list(any)
  description = "A list of explicit dependencies"
}

variable "vpc" {
  type = any
}

variable cluster_name {
  type        = string
  default     = null
  description = "A name of the Amazon EKS cluster"
}

variable "cluster" {
  type = any
}

variable "artifacts" {
  type = any
}

variable "config_path" {
  description = "location of the kubeconfig file"
  default     = "~/.kube/config"
}

variable "cluster_instance_class" {
  type        = string
  description = "Instance class used for Aurora"
  default     = "db.t3.small"
}

variable "db_admin_name" {
  type    = string
  default = "dbadmin"
}

variable "db_admin_password" {
  type    = string
  default = ""
}
