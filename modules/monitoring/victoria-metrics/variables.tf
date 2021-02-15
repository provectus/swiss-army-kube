variable "argocd" {
  type        = map(string)
  description = "A set of values for enabling deployment through ArgoCD"
  default     = {}
}

variable "conf" {
  type        = map(string)
  description = "A custom configuration for deployment"
  default     = {}
}

variable "namespace" {
  type        = string
  default     = ""
  description = "A name of the existing namespace"
}

variable "namespace_name" {
  type        = string
  default     = "monitoring"
  description = "A name of namespace for creating"
}

variable "module_depends_on" {
  default     = []
  type        = list(any)
  description = "A list of explicit dependencies"
}

variable "cluster_name" {
  type        = string
  default     = null
  description = "A name of the Amazon EKS cluster"
}

variable "domains" {
  type        = list(string)
  default     = ["local"]
  description = "A list of domains to use for ingresses"
}

variable "chart_version" {
  type        = string
  description = "A Helm Chart version"
  default     = "0.8.10"
}

variable "release_name" {
  type        = string
  description = "A release name"
  default     = "victoria-metrics-cluster"
}

variable "chart_name" {
  type        = string
  description = "A chart name"
  default     = "victoria-metrics-cluster"
}

variable "chart_repository" {
  type        = string
  description = "A chart repository"
  default     = "https://victoriametrics.github.io/helm-charts/"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A tags for attaching to new created AWS resources"
}
