# For depends_on queqe
variable "module_depends_on" {
  default = []
}

variable "argo_events_namespace" {
  description = "Namespace where argo-events install"
}

variable "cluster_name" {
  description = "Cluster name"
}

variable "environment" {
  description = "Environment name"
}

variable "project" {
  description = "Name of project"
}

variable "aws_region" {
  description = "AWS region"
}