variable "cluster_name" {
  type        = string
  default     = null
  description = "A name of the Amazon EKS cluster"
}
variable "domains" {
  type        = list(string)
  default     = []
  description = "A list of domains to use for ingresses"
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
variable "namespace_name" {
  type        = string
  default     = "argo"
  description = "A name of namespace for creating"
}
variable "install_cd" {
  default = true
}
variable "install_events" {
  default = true
}
variable "install_workflows" {
  default = true
}
variable "module_depends_on" {
  default     = []
  type        = list(any)
  description = "A list of explicit dependencies"
}

variable "cluster_oidc_url" {
  type        = string
  description = "An OIDC endpoint of the EKS cluster"
  default     = ""
}
