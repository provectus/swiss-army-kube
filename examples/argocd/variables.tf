variable "cluster_name" {
  default     = "swiss-army-kube-sub2zero"
  type        = string
  description = "A name of the Amazon EKS cluster"
}

variable "region" {
  default     = "eu-north-1"
  type        = string
  description = "Set default region"
}

variable "availability_zones" {
  default     = ["eu-north-1a", "eu-north-1b"]
  type        = list(any)
  description = "Availability zones for project"
}

variable "environment" {
  default     = "dev"
  type        = string
  description = "A value that will be used in annotations and tags to identify resources with the `Environment` key"
}

variable "project" {
  default     = "SWISS"
  type        = string
  description = "A value that will be used in annotations and tags to identify resources with the `Project` key"
}

variable "domain_name" {
  default     = "swiss.sak.ninja"
  type        = string
  description = "Default domain name"
}

variable "argocd" {
  default = {
    repository = "swiss-army-kube"
    branch     = "testLab"
    owner      = "sub2zero"
  }
  type        = map(string)
  description = "A set of values for enabling deployment through ArgoCD"
}

variable "cluster_version" {
  type        = string
  description = "EKS cluster version"
  default     = "1.21"
}

variable "vpc_id" {
  type        = string
  default     = null
  description = "An ID of the existing AWS VPC"
}

variable "container_runtime" {
  type        = string
  default     = "docker"
  description = "Type of container runtime interface. Allowed values: docker/containerd"
  validation {
    condition     = can(regex("^(docker|containerd)$", var.container_runtime))
    error_message = "Must be docker or containerd."
  }
}

variable "domains" {
  type        = list(string)
  default     = []
  description = "A list of domains to use for ingresses"
}

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
  type        = string
  description = "EC2 on_demand Instance type"
  default     = "m5.large"
}

variable "on_demand_common_override_instance_types" {
  type        = list(string)
  description = "EC2 on_demand override instance types"
  default     = ["m5.large", "m5.xlarge", "m5.2xlarge"]
}

variable "on_demand_common_allocation_strategy" {
  type        = string
  description = "Strategy to use when launching on-demand instances. Valid values: prioritized"
  default     = "prioritized"
}

variable "on_demand_common_base_capacity" {
  type        = string
  description = "Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances"
  default     = "0"

}

variable "on_demand_common_percentage_above_base_capacity" {
  type        = string
  description = "Percentage split between on-demand and Spot instances above the base on-demand capacity"
  default     = "100"
}

variable "on_demand_common_asg_recreate_on_change" {
  type        = string
  description = "Recreate the autoscaling group when the Launch Template or Launch Configuration change."
  default     = "true"
}


# enable control plane cloudwatch logging
variable "cloudwatch_logging_enabled" {
  type        = bool
  description = "Send EKS control plane logs to cloudwatch"
  default     = false
}


variable "cloudwatch_cluster_log_types" {
  type        = list(any)
  description = "log types that you want to send to cloudwatch"
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}


variable "cloudwatch_cluster_log_retention_days" {
  type        = number
  description = "logs retention period in days (1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, 0). 0 means logs will never expire."
  default     = 90
}



# On-demand GPU instance
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
  type        = string
  description = "EC2 on_demand Instance type"
  default     = "g4dn.xlarge"
}

variable "on_demand_gpu_override_instance_types" {
  type        = list(string)
  description = "EC2 on_demand Instance types for overriding"
  default     = ["g4dn.xlarge"]
}

variable "on_demand_gpu_resource_count" {
  type        = number
  description = "A number of GPUs resopurces for the instance type"
  default     = 1
}

variable "on_demand_gpu_allocation_strategy" {
  type        = string
  description = "Strategy to use when launching on-demand instances. Valid values: prioritized"
  default     = "prioritized"
}

variable "on_demand_gpu_base_capacity" {
  type        = string
  description = "Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances"
  default     = "0"
}

variable "on_demand_gpu_percentage_above_base_capacity" {
  type        = string
  description = "Percentage split between on-demand and Spot instances above the base on-demand capacity"
  default     = "100"
}

variable "on_demand_gpu_asg_recreate_on_change" {
  type        = string
  description = "Recreate the autoscaling group when the Launch Template or Launch Configuration change."
  default     = "true"
}

# On-demand CPU instance
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
  type        = string
  description = "EC2 on_demand Instance type"
  default     = "c5.xlarge"
}

variable "on_demand_cpu_override_instance_types" {
  type        = list(string)
  description = "EC2 on_demand Instance type"
  default     = ["c5.xlarge", "c5.2xlarge", "c5n.xlarge"]
}

variable "on_demand_cpu_allocation_strategy" {
  type        = string
  description = "Strategy to use when launching on-demand instances. Valid values: prioritized"
  default     = "prioritized"
}

variable "on_demand_cpu_base_capacity" {
  type        = string
  description = "Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances"
  default     = "0"

}

variable "on_demand_cpu_percentage_above_base_capacity" {
  type        = string
  description = "Percentage split between on-demand and Spot instances above the base on-demand capacity"
  default     = "100"
}

variable "on_demand_cpu_asg_recreate_on_change" {
  type        = string
  description = "Recreate the autoscaling group when the Launch Template or Launch Configuration change."
  default     = "true"
}