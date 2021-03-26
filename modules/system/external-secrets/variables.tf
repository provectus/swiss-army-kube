variable "namespace" {
  type        = string
  default     = "kube-system"
  description = "A name of the existing namespace"
}

variable "aws_region" {
  type        = string
  description = "A name of the AWS region (us-central-1, us-west-2 and etc.)"
  default     = ""
}

variable "chart_version" {
  type        = string
  description = "A Helm Chart version"
  default     = "6.0.0"
}

variable "poller_interval" {
  type        = string
  description = "Interval of refreshing values from secrets manager in ms"
  default     = "30000"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "cluster_oidc_url" {
  type        = string
  description = "oidc issuer url of the eks cluster"
}

variable "chart_repository" {
  type        = string
  description = "A chart repository"
  default     = "https://external-secrets.github.io/kubernetes-external-secrets/"
}

variable "chart_values" {
  default     = ""
  description = "Chart values"
}

variable "aws_assume_role_arn" {
  default     = ""
  description = "A role to assume. If left blank a new role will be created"
}

variable "secret_manager_full_access" {
  default     = false
  description = <<EOT
  By setting this to true, the assumable role that is created for the Service Account attached to the External-Secrets application will have full access to all AWS Sercret Manager keys prefixed the name of the cluster. 
  We recommend setting this to false and instead creating roles with fine-granular access policies for each ExternalSecret you define, and allow the role created here to assume those roles.
  EOT
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
  type        = map(string)
  default     = {}
  description = "A tags for attaching to new created AWS resources"
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
