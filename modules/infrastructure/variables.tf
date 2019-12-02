variable "region" {
  type        = string
}

variable "cluster_name" {
  type        = string
  description = "Name of cluster."
}

variable "cluster_size" {
  type        = number
  description = "Number of desired instances."
}

variable "spot_price" {
  default = ""
}

variable "network" {
  type        = number
  description = "Number would be used to template CIDR 10.X.0.0/16."
  default     = 10
}

variable "admin_arns" {
  type        = list(string)  
  description = "ARNs of users which would have admin permissions."
  default     = []
}

variable "eks_instance_type" {
  description = "Instance type to use for running EKS"
  default = "m5.large"
}
