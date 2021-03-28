variable "module_depends_on" {
  default = []
}

variable "cluster_name" {
  description = "Name of the kubernetes cluster"
}

variable "domains" {
  description = "domain name for ingress"
}

variable "vpc_id" {
  description = "domain name for ingress"
}

variable "certificates_arns" {
  type        = list(string)
  description = "List of certificates to attach to ingress"
  default     = []
}

variable "namespace" {
  type        = string
  description = ""
  default     = "ingress-system"
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

variable "tags" {
  type    = map(string)
  default = {}
}