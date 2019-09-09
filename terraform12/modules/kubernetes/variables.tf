variable "environment" {
  type        = "string"
  description = "Environment"
}

variable "cluster_name" {
  type        = "string"
  description = "Name of cluster."
}

variable "aws_region" {
  type        = "string"
  description = "AWS Region"
}


variable "vpc_id" {
  type        = "string"
  description = "VPC id"
}

variable "private_subnets" {
  type        = "list"
  description = "vpc private subnets"
}

variable "max_cluster_size" {
  type        = "string"
  description = "Number of max instances."
  default     = "2"
}

variable "desired_capacity" {
  type        = "string"
  description = "Number of desired instances."
}

variable "cluster_version" {
  type        = "string"
  description = "Number of desired instances."
}

variable "instance_type" {
  type        = "string"
  description = "EC2 Instance type"
}

variable "spot_price" {
  type    = "string"
  default = "0.5"
}

# This variable is intended to lock creation of modules before kubernetes_cluster_role_binding.tiller
variable deps {
  default = []

  type = "list"
}

variable "admin_arns" {
  type        = list(map(string))
  description = "ARNs of users which would have admin permissions."
  default     = []
}

variable "domain" {
  type    = "string"
  description = "Domain name for Extarnal DNS service"
  default = "set_domain"
}

variable "cert_manager_email" {
  type        = "string"
  description = "Set email for Cert manager notifications"
}
