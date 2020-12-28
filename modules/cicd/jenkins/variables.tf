# For depends_on queqe
variable "module_depends_on" {
  default     = []
  type        = list(any)
  description = "A list of explicit dependencies"
}

variable "domains" {
  type        = list(string)
  default     = []
  description = "A list of domains to use for ingresses"
}

variable "jenkins_password" {
  description = "Password for jenkins admin"
  default     = "password"
}

variable "config_path" {
  description = "location of the kubeconfig file"
  default     = "~/.kube/config"
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

variable "cluster_oidc_arn" {
  type        = string
  description = "An OIDC arn of the EKS cluster"
  default     = ""
}

variable "cluster_oidc_url" {
  type        = string
  description = "An OIDC endpoint of the EKS cluster"
  default     = ""
}

variable "agent_policy" {
  description = "Policy attached to Jenkins agents IAM role"
  default     = ""
}

variable "master_policy" {
  description = "Policy attached to Jenkins master IAM role"
  default     = ""
}
