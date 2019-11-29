variable "region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "Name of cluster."
  default     = "test"
}

variable "cluster_size" {
  description = "Number of desired instances."
  default     = "2"
}

variable "spot_price" {
  default = ""
}

variable "network" {
  description = "Number would be used to template CIDR 10.X.0.0/16."
  default = 10
}

variable "admin_arns" {
  description = "ARNs of users which would have admin permissions."
  default     = []
}

variable "eks_instance_type" {
  description = "Instance type to use for running EKS"
  default = "m5.large"
}