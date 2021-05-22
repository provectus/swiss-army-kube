variable "cluster_name" {
  default     = "swiss-army"
  type        = string
  description = "A name of the Amazon EKS cluster"
}

variable "region" {
  default     = "eu-central-1"
  type        = string
  description = "Set default region"
}

variable "availability_zones" {
  default     = ["eu-central-1a", "eu-central-1b"]
  type        = list(any)
  description = "Availability zones for project, minimum 2"
}

variable "zone_id" {
  default     = ""
  type        = string
  description = "Default zone id for root domain" #like Z04917561CQAI9UAF27D6
}

variable "environment" {
  default     = "dev"
  type        = string
  description = "A value that will be used in annotations and tags to identify resources with the `Environment` key"
}

variable "project" {
  default     = "SWISSARMY"
  type        = string
  description = "A value that will be used in annotations and tags to identify resources with the `Project` key"
}

variable "domain_name" {
  default     = "sak.ninja"
  type        = string
  description = "Default domain name"
}

#Argocd sync repository
variable "argocd" {
  default = {
    repository = "swiss-army-kube"
    branch     = "master"
    owner      = "provectus"
  }
  type        = map(string)
  description = "A set of values for enabling deployment through ArgoCD"
}
