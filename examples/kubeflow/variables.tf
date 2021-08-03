variable "cluster_name" {
  default     = "kubeflow"
  type        = string
  description = "A name of the Amazon EKS cluster"
}

variable "region" {
  default     = "eu-west-3"
  type        = string
  description = "Set default region"
}

variable "availability_zones" {
  default     = ["eu-west-3a", "eu-west-3b"]
  type        = list(any)
  description = "Availability zones for project, minimum 2"
}

variable "zone_id" {
  type        = string
  description = "Default zone id for root domain" #like Z04917561CQAI9UAF27D6
  default     = "Z02149423PVQ0YMP19F13"
}

variable "environment" {
  default     = "ml"
  type        = string
  description = "A value that will be used in annotations and tags to identify resources with the `Environment` key"
}

variable "project" {
  default     = "KUBEFLOW"
  type        = string
  description = "A value that will be used in annotations and tags to identify resources with the `Project` key"
}

variable "domain_name" {
  default     = "edu.provectus.io"
  type        = string
  description = "Default domain name"
}

#Argocd sync repository
variable "argocd" {
  default = {
    repository = "swiss-army-kube"
    branch     = "kubeflow"
    owner      = "provectus"
  }
  type        = map(string)
  description = "A set of values for enabling deployment through ArgoCD"
}

variable "cognito_users" {
  type    = list(map(string))
  default = []
}