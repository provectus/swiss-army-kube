variable "cidr" {
  type        = string
  description = "TBD"
  default     = null
}


variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = null
}


variable "network_delimiter" {
  type        = string
  description = "TBD"
  default     = "8"
}

variable "network" {
  type        = string
  description = "Number would be used to template CIDR 10.X.0.0/16."
  default     = "10"
}

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
  default     = "cluster-name"
  description = "A name of the Amazon EKS cluster"
}

variable "availability_zones" {
  description = "Availability zones for project"
  type        = list(any)
  default     = []
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A tags for attaching to new created AWS resources"
}
