# For depends_on queqe
variable "module_depends_on" {
  default     = []
  type        = list(any)
  description = "A list of explicit dependencies"
}

variable "aws_private" {
  type        = bool
  description = "Set true or false to use private or public infrastructure"
  default     = false
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

variable "cluster_name" {
  type        = string
  default     = null
  description = "A name of the Amazon EKS cluster"
}

variable "vpc_id" {
  type        = string
  default     = null
  description = "An ID of the existing AWS VPC"
}

variable "mainzoneid" {
  type        = string
  default     = ""
  description = "An ID of the root Route53 zone for creating sub-domains"
}

variable "config_path" {
  description = "location of the kubeconfig file"
  default     = "~/.kube/config"
}

variable "domains" {
  type        = list(string)
  default     = []
  description = "A list of domains to use for ingresses"
}

#Cert-manager
variable "cert_manager_email" {
  type        = string
  default     = "test@example.com"
  description = "Email to cert-manager"
}

variable "cluster_oidc_url" {
  type        = string
  description = "An OIDC endpoint of the EKS cluster"
  default     = ""
}

variable "cluster_oidc_arn" {
  type        = string
  description = "An OIDC arn of the EKS cluster"
  default     = ""
}

variable "cluster_roles" {
  description = "Additional cluster roles."
  type = list(object({
    cluster_group = string
    roles = list(object({
      role_resources  = list(string)
      role_verbs      = list(string)
      role_api_groups = list(string)
    }))
  }))
  default = []
}
