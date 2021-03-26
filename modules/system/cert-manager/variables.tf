variable "cluster_name" {
  type    = string
  default = ""
}

variable "domains" {
  type    = list(string)
  default = []
}

variable "email" {
  type    = string
  default = ""
}

variable "environment" {
  type    = string
  default = ""
}

variable "module_depends_on" {
  type    = list(any)
  default = []
}

variable "namespace" {
  type    = string
  default = "cert-manager"
}

variable "project" {
  type    = string
  default = ""
}

variable "vpc_id" {
  type = string
}

variable "zone_id" {
  type = string
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
