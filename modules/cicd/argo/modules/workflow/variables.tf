# For depends_on queqe
variable "module_depends_on" {
  default = []
}

variable "namespace" {
  default = "argo-workflow"
}

variable "s3_bucket" {
  description = "Bucket name in s3"
  default     = ""
}

variable "workflow_conf" {
  default = {}
}

variable "argo_events_namespace" {
  type = string
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
  description = "Name of the kubernetes cluster"
}

variable "cluster_oidc_url" {
  type = string
}