variable "aws_private" {
  type        = bool
  description = "Set true or false to use private or public infrastructure"
  default     = false
}

variable "conf" {
  type        = map(string)
  description = "A custom configuration for deployment"
  default     = {}
}

variable "hosted_zone_domain" {
  type        = string
  description = "A route53 hosted zone domain to reuse"
}

variable "hosted_zone_subdomain" {
  type        = string
  default     = null
  description = "A route53 hosted zones domains to create, linked to the hosted_zone_domain"
}

variable "namespace" {
  type        = string
  default     = "kube-system"
  description = "A name of the existing namespace"
}

variable "namespace_name" {
  type        = string
  default     = "external-dns"
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
  default     = "3.4.1"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A tags for attaching to new created AWS resources"
}

variable "vpc_id" {
  type        = string
  default     = null
  description = "An ID of the existing AWS VPC"
}

variable "argocd" {
  type        = map(string)
  description = "A set of variables for enabling ArgoCD"
  default = {
    namespace  = ""
    path       = ""
    repository = ""
    branch     = ""
  }
}