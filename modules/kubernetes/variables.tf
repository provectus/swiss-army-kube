variable "environment" {
  type        = string
  description = "Environment Use in tags and annotations for identify EKS cluster"
}

variable "cluster_name" {
  type        = string
  description = "Name of EKS cluster"
}

variable "cluster_version" {
  type        = string
  description = "EKS cluster version"
}

variable "aws_region" {
  type        = string
  description = "Name of aws region (like us-west-1, us-east-1)"
}

variable "vpc_id" {
  type        = string
  description = "VPC id"
}

variable "private_subnets" {
  type        = list
  description = "vpc private subnets"
}

variable "on_demand_max_cluster_size" {
  type        = string
  description = "Max number of on demand instances in EKS autoscaling group"
  default     = "2"
}
 
variable "spot_max_cluster_size" {
  type        = string
  description = "Max number of spot instances in EKS autoscaling group"
  default     = "2"
}

variable "on_demand_desired_capacity" {
  type        = string
  description = "Desired number of on_demand instances in EKS autoscaling group"
}

variable "spot_desired_capacity" {
  type        = string
  description = "Desired number of spot instances in EKS autoscaling group"
}

variable "on_demand_instance_type" {
  type        = string
  description = "EC2 on_demand Instance type"
}

variable "spot_instance_type" {
  type        = string
  description = "EC2 spot Instance type"
}

variable "spot_price" {
  type    = string
  default = "0.5"
  description = "Price per/hour in $"
}

variable "admin_arns" {
  type        = list(string)
  description = "ARNs of users which would have admin permissions."
  default     = []
}

variable "domain" {
  type    = string
  description = "Domain name for Extarnal DNS service"
  default = "set_domain"
}

variable "cert_manager_email" {
  type        = string
  description = "Set email for Cert manager notifications"
}
