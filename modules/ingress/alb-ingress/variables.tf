# For depends_on queqe
variable module_depends_on {
  default     = []
  type        = list(any)
  description = "A list of explicit dependencies"
}

variable cluster_name {
  type        = string
  default     = null
  description = "A name of the Amazon EKS cluster"
}

variable "domains" {
  type        = list(string)
  default     = []
  description = "A list of domains to use for ingresses"
}

variable "vpc_id" {
  type        = string
  default     = null
  description = "An ID of the existing AWS VPC"
}

variable aws_region {
  type        = string
  default     = null
  description = "A name of the AWS region (us-central-1, us-west-2 and etc.)"
}

variable "config_path" {
  description = "location of the kubeconfig file"
  default     = "~/.kube/config"
}

variable "certificates_arns" {
  type        = list(string)
  description = "List of certificates to attach to ingress"
  default     = []
}

variable "cluster_oidc_url" {
  type        = string
  description = "An OIDC endpoint of the EKS cluster"
  default     = ""
}
