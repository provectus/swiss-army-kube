variable "environment" {
  type        = string
  default     = null
  description = "A value that will be used in annotations and tags to identify resources with the `Environment` key"
}

variable "project" {
  type        = string
  default     = null
  description = "A value that will be used in annotations and tags to identify resources with the `Project` key"
}

variable "cluster_name" {
  type        = string
  default     = "test"
  description = "A name of the Amazon EKS cluster"
}

variable "cluster_version" {
  type        = string
  description = "EKS cluster version"
  default     = "1.18"
}

variable "vpc_id" {
  type        = string
  default     = null
  description = "An ID of the existing AWS VPC"
}

variable "availability_zones" {
  description = "Availability zones for project"
  type        = list(any)
  default     = []
}

variable "subnets" {
  type        = list(any)
  description = "vpc subnets"
}

variable "wait_for_cluster_interpreter" {
  type        = list(string)
  description = "Interpreter in which to run 'wait for cluster' command"
  default     = ["/bin/sh", "-c"]
}

variable "aws_auth_user_mapping" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_role_mapping" {
  description = "Additional IAM ro9les to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

<<<<<<< HEAD

# On-demand instance
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
  default     = "m5.large"
}

variable "on_demand_common_override_instance_types" {
  description = "EC2 on_demand override instance types"
  default     = ["m5.large", "m5.xlarge", "m5.2xlarge"]
=======
variable enable_secret_encryption {
  type        = bool
  description = "Set to true to create a KMS key to be used as a CMK (Cluster Master Key) for secret encryption"
  default     = false
>>>>>>> pr/168
}

variable enable_irsa {
  type        = bool
  description = "Set to true to enable IAM Roles for Service Accounts"
  default     = false
}

variable "workers_additional_policies" {
  type  = list
  default = []
  description = "List of ARNs of additional policies to attach to workers"
}

variable "tags" {
  type        = map(string)
  description = "Tags to add to AWS resources"
  default     = {}
}

variable "worker_groups" {
  description = "A list of maps defining worker group configurations to be defined using AWS Launch Templates. See workers_group_defaults_defaults in https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/local.tf"
  type        = any
  default     = []
}

variable "worker_groups_launch_template" {
  description = "A list of maps defining worker group configurations to be defined using AWS Launch Templates. See workers_group_defaults_defaults in https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/local.tf"
  type        = any
  default     = []
}

variable "workers_additional_policies" {
  type  = list
  default = []
  description = "List of ARNs of additional policies to attach to workers"
}

variable "tags" {
  type        = map(string)
  description = "Tags to add to AWS resources"
  default     = {}
}
