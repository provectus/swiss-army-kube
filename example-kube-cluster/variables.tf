variable "region" {
  description = "Name the aws region (us-central-1, us-west-2 and etc.)"
}
variable "cluster_name" {
  description = "Name of cluster"
}

variable "domain" {
  description = "domain name for ingress"
}

variable "cluster_size" {
  description = "Number of desired instances."
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
