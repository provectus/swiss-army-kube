# For depends_on queqe
variable "module_depends_on" {
  default = []
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

variable "admin_arns" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "user_arns" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

# On-demand instance
variable "on_demand_common_enabled" {
  type        = bool
  description = "Enable common on-demand instances"
  default     = true
}

variable "on_demand_common_max_cluster_size" {
  type        = string
  description = "Max number of on demand instances in EKS autoscaling group"
  default     = "2"
}

variable "on_demand_common_min_cluster_size" {
  type        = string
  description = "Min number of on demand instances in EKS autoscaling group"
  default     = "1"
}

variable "on_demand_common_desired_capacity" {
  type        = string
  description = "Desired number of on_demand instances in EKS autoscaling group"
  default     = "1"
}

variable "on_demand_common_instance_type" {
  description = "EC2 on_demand Instance type"
  default     = ["m5.large"]
}

# On-demand GPU instance
variable "on_demand_gpu_enabled" {
  type        = bool
  description = "Enable gpu on-demand instances"
  default     = false
}

variable "on_demand_gpu_max_cluster_size" {
  type        = string
  description = "Max number of on demand instances in EKS autoscaling group"
  default     = "2"
}

variable "on_demand_gpu_min_cluster_size" {
  type        = string
  description = "Min number of on demand instances in EKS autoscaling group"
  default     = "0"
}

variable "on_demand_gpu_desired_capacity" {
  type        = string
  description = "Desired number of on_demand instances in EKS autoscaling group"
  default     = "0"
}

variable "on_demand_gpu_instance_type" {
  description = "EC2 on_demand Instance type"
  default     = ["p2.xlarge"]
}

# On-demand CPU instance
variable "on_demand_cpu_enabled" {
  type        = bool
  description = "Enable cpu on-demand instances"
  default     = false
}

variable "on_demand_cpu_max_cluster_size" {
  type        = string
  description = "Max number of on demand instances in EKS autoscaling group"
  default     = "2"
}

variable "on_demand_cpu_min_cluster_size" {
  type        = string
  description = "Min number of on demand instances in EKS autoscaling group"
  default     = "0"
}

variable "on_demand_cpu_desired_capacity" {
  type        = string
  description = "Desired number of on_demand instances in EKS autoscaling group"
  default     = "0"
}

variable "on_demand_cpu_instance_type" {
  description = "EC2 on_demand Instance type"
  default     = ["c5.xlarge"]
}