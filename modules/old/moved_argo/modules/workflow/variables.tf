# For depends_on queqe
variable "module_depends_on" {
  default     = []
  type        = list(any)
  description = "A list of explicit dependencies"
}

variable "namespace" {
  type        = string
  default     = null
  description = "A name of the existing namespace"
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
  default     = null
  description = "A name of the Amazon EKS cluster"
}

variable "cluster_oidc_url" {
  type        = string
  description = "An OIDC endpoint of the EKS cluster"
  default     = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
