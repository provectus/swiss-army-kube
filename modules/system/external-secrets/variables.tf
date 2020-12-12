variable "aws_region" {
  type        = string
  description = "AWS Region with Secrets manager to access default - current"
  default     = ""
}

variable "chart_version" {
  type        = string
  description = "Version of the helm chart for External Secrets"
  default     = "6.0.0"
}

variable "poller_interval" {
  type        = string
  description = "Interval of refreshing values from secrets manager in ms"
  default     = "30000"
}

variable "cluster_output" {
  description = "cluster output object from Kubernetes module"

}

variable "chart_repository" {
  type    = string
  default = "https://external-secrets.github.io/kubernetes-external-secrets/"
}

variable "chart_values" {
  default     = ""
  description = "Chart values"
}

variable "aws_assume_role_arn" {
  default     = ""
  description = "A role to assume"
}

variable "chart_parameters" {
  default     = []
  description = "A list of parameters that will override defaults"
}

variable "chart_parameters_as_string" {
  default     = []
  description = "A list of parameters that will override defaults"
}

variable "tags" {
  default = {}
}

variable "allowed_secrets_prefix" {
  type        = string
  description = "Prefix of for secrets we should be able to access from the external-secrets app?"
  default     = "/eks/"
}
variable "argocd" {
  type        = map(string)
  description = "A set of values for enabling deployment through ArgoCD"
  default     = {}
}
