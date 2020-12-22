variable environment {
  type        = string
  default     = null
  description = "A value that will be used in annotations and tags to identify resources with the `Environment` key"
}

variable project {
  type        = string
  default     = null
  description = "A value that will be used in annotations and tags to identify resources with the `Project` key"
}

variable cluster_name {
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


variable availability_zones {
  description = "A list of the availability zones to use"
  type        = list
  default     = []
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
  default     = ["m5.large", "m5.xlarge", "m5.2xlarge"]
}

variable "on_demand_common_allocation_strategy" {
  description = "Strategy to use when launching on-demand instances. Valid values: prioritized"
  default     = "prioritized"
}

variable "on_demand_common_base_capacity" {
  description = "Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances"
  default     = "0"

}

variable "on_demand_common_percentage_above_base_capacity" {
  description = "Percentage split between on-demand and Spot instances above the base on-demand capacity"
  default     = "0"
}

variable "on_demand_common_asg_recreate_on_change" {
  description = "Recreate the autoscaling group when the Launch Template or Launch Configuration change."
  default     = "false"
}

# Spot instance
variable "spot_max_cluster_size" {
  type        = string
  description = "Max number of spot instances in EKS autoscaling group"
  default     = "2"
}

variable "spot_min_cluster_size" {
  type        = string
  description = "Min number of spot instances in EKS autoscaling group"
  default     = "0"
}

variable "spot_desired_capacity" {
  type        = string
  description = "Desired number of spot instances in EKS autoscaling group"
  default     = "0"
}

variable "spot_instance_type" {
  description = "EC2 spot Instance type"
  default     = ["m5.large", "m5.xlarge", "m5.2xlarge"]
}

variable "spot_instance_pools" {
  description = "Number of Spot pools per availability zone to allocate capacity. EC2 Auto Scaling selects the cheapest Spot pools and evenly allocates Spot capacity across the number of Spot pools that you specify."
  default     = "10"
}

variable "spot_asg_recreate_on_change" {
  description = "Recreate the autoscaling group when the Launch Template or Launch Configuration change."
  default     = "false"
}

variable "spot_allocation_strategy" {
  description = "Valid options are 'lowest-price' and 'capacity-optimized'. If 'lowest-price', the Auto Scaling group launches instances using the Spot pools with the lowest price, and evenly allocates your instances across the number of Spot pools. If 'capacity-optimized', the Auto Scaling group launches instances using Spot pools that are optimally chosen based on the available Spot capacity."
  default     = "prioritized"
}

variable "spot_max_price" {
  type        = string
  default     = "1"
  description = "Maximum price per unit hour that the user is willing to pay for the Spot instances. Default is the on-demand price"
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
  description = "EC2 on_demand Instance type"
  default     = ["p2.xlarge", "g4dn.xlarge", "p3.2xlarge"]
}

variable "on_demand_gpu_allocation_strategy" {
  description = "Strategy to use when launching on-demand instances. Valid values: prioritized"
  default     = "prioritized"
}

variable "on_demand_gpu_base_capacity" {
  description = "Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances"
  default     = "0"

}

variable "on_demand_gpu_percentage_above_base_capacity" {
  description = "Percentage split between on-demand and Spot instances above the base on-demand capacity"
  default     = "0"
}

variable "on_demand_gpu_asg_recreate_on_change" {
  description = "Recreate the autoscaling group when the Launch Template or Launch Configuration change."
  default     = "false"
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
  description = "EC2 on_demand Instance type"
  default     = ["c5.xlarge", "c5.2xlarge", "c5n.xlarge"]
}

variable "on_demand_cpu_allocation_strategy" {
  description = "Strategy to use when launching on-demand instances. Valid values: prioritized"
  default     = "prioritized"
}

variable "on_demand_cpu_base_capacity" {
  description = "Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances"
  default     = "0"

}

variable "on_demand_cpu_percentage_above_base_capacity" {
  description = "Percentage split between on-demand and Spot instances above the base on-demand capacity"
  default     = "0"
}

variable "on_demand_cpu_asg_recreate_on_change" {
  description = "Recreate the autoscaling group when the Launch Template or Launch Configuration change."
  default     = "false"
}
