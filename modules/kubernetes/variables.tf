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
  type        = string
  description = "Name of EKS cluster"
  default     = "test"
}

variable "cluster_version" {
  type        = string
  description = "EKS cluster version"
  default     = "1.14"
}

variable "vpc_id" {
  type        = string
  description = "VPC id"
}

variable "subnets" {
  type        = list
  description = "vpc subnets"
}

variable "on_demand_max_cluster_size" {
  type        = string
  description = "Max number of on demand instances in EKS autoscaling group"
  default     = "2"
}

variable "on_demand_min_cluster_size" {
  type        = string
  description = "Max number of on demand instances in EKS autoscaling group"
  default     = "0"
}

variable "spot_max_cluster_size" {
  type        = string
  description = "Max number of spot instances in EKS autoscaling group"
  default     = "2"
}

variable "spot_min_cluster_size" {
  type        = string
  description = "Max number of spot instances in EKS autoscaling group"
  default     = "0"
}

variable "on_demand_desired_capacity" {
  type        = string
  description = "Desired number of on_demand instances in EKS autoscaling group"
  default     = "1"
}

variable "spot_desired_capacity" {
  type        = string
  description = "Desired number of spot instances in EKS autoscaling group"
  default     = "0"
}

variable "on_demand_instance_type" {
  type        = string
  description = "EC2 on_demand Instance type"
  default     = "c5.xlarge"
}

variable "spot_instance_type" {
  type        = string
  description = "EC2 spot Instance type"
  default     = "c5.xlarge"
}

variable "spot_price" {
  type        = string
  default     = "0.5"
  description = "Price per/hour in $"
}

variable "admin_arns" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}
