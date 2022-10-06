variable "cluster_name" {
  default     = "swiss-army-kube-sub2zero"
  type        = string
  description = "A name of the Amazon EKS cluster"
}

variable "region" {
  default     = "eu-north-1"
  type        = string
  description = "Set default region"
}

variable "availability_zones" {
  default     = ["eu-north-1a", "eu-north-1b"]
  type        = list(any)
  description = "Availability zones for project"
}

variable "environment" {
  default     = "dev"
  type        = string
  description = "A value that will be used in annotations and tags to identify resources with the `Environment` key"
}

variable "project" {
  default     = "SWISS"
  type        = string
  description = "A value that will be used in annotations and tags to identify resources with the `Project` key"
}

variable "domain_name" {
  default     = "swiss.sak.ninja"
  type        = string
  description = "Default domain name"
}

variable "argocd" {
  default = {
    repository = "swiss-army-kube"
    branch     = "testLab"
    owner      = "sub2zero"
  }
  type        = map(string)
  description = "A set of values for enabling deployment through ArgoCD"
}
