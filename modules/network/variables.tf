variable "network" {
  type        = string
  description = "Number would be used to template CIDR 10.X.0.0/16."
  default     = "10"
}

variable "environment" {
  type        = string
  description = "Environment"
}

variable "cluster_name" {
  type        = string
  description = "Name of cluster."
  default     = "cluster-name"
}

variable "availability_zones" {
  description = "A list of availability zones where need to create subnets"
  type        = list
}
