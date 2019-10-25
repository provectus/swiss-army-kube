variable "cluster_name" {
  type        = string
  description = "Name of cluster."
  default     = "test"
}

variable "cluster_size" {
  type        = number
  description = "Number of desired instances."
  default     = 5
}

variable "cluster_zones" {
  type        = list(string)
  description = "Availlability zones for EKS"
  default     = []
}

variable "spot_price" {
  type    = string
  default = ""
}

variable "instance_type" {
  type        = string
  description = "Instance type for instances for Kubernetes workes nodes"
  default     = "t3.medium"
}

variable "network" {
  type        = string
  description = "CIDR block for vpc"
  default     = "10.0.0.0/16"
}

variable "network_delim" {
  type        = number
  description = "Number of additional bits with which to extend the network"
  default     = 8
}

variable "admin_arns" {
  type        = list(string)
  description = "ARNs of users which would have admin permissions."
  default     = []
}

