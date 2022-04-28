variable "cluster_name" {
  default     = "dl-sak"
  type        = string
  description = "A name of the Amazon EKS cluster"
}

variable "region" {
  default     = "us-west-1"
  type        = string
  description = "Set default region"
}

variable "availability_zones" {
  default     = ["us-west-1a", "us-west-1b"]
  type        = list(any)
  description = "Availability zones for project, minimum 2"
}

variable "zone_id" {
  default     = "Z02149423PVQ0YMP19F13"
  type        = string
  description = "Default zone id for root domain"
}

variable "environment" {
  default     = "dev"
  type        = string
  description = "A value that will be used in annotations and tags to identify resources with the `Environment` key"
}

variable "project" {
  default     = "dl"
  type        = string
  description = "A value that will be used in annotations and tags to identify resources with the `Project` key"
}

variable "domain_name" {
  default     = "dev-sak.edu.provectus.io"
  type        = string
  description = "Default domain name"
}

#Argocd sync repository
variable "argocd" {
  default = {
    repository = "swiss-army-kube"
    branch     = "issue_196_check_modules"
    owner      = "provectus"
  }
  type        = map(string)
  description = "A set of values for enabling deployment through ArgoCD"
}
