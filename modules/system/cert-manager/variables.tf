variable "namespace" {
  type        = string
  default     = ""
  description = "A name of the existing namespace"
}

variable "namespace_name" {
  type        = string
  default     = "cert-manager"
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

variable "chart_version" {
  type        = string
  description = "A Helm Chart version"
  default     = "1.1.0"
}

variable "aws_private" {
  type        = bool
  description = "Set true or false to use private or public infrastructure"
  default     = false
}

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

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A tags for attaching to new created AWS resources"
}

variable "hostedZoneID" {
  type        = string
  default     = "zoneID"
  description = "Route53 zoneID"
}

variable "email" {
  type        = string
  default     = "email@example.com"
  description = "Cert-manager email"
}

variable "domain" {
  type        = string
  description = "domain name for ingress"
  default     = "example.com"
}
