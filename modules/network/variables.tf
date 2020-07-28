variable "cidr" {
  type        = string
  description = "TBD"
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
  description = "Environment Use in tags and annotations for identify EKS cluster"
}

variable "project" {
  type        = string
  description = "Project Use in tags and annotations for identify EKS cluster"
}

variable "cluster_name" {
  type        = string
  description = "Name of the kubernetes cluster"
  default     = "test"
}

variable "availability_zones" {
  description = "A list of availability zones where need to create subnets"
  type        = list
  default     = []
}
