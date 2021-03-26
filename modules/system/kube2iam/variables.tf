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

variable "kube2iam_def" {
  type        = string
  description = "The resource definition for kube2iam"
  default     = null //default is constructed dynmaically. See locals.tf
}

variable "base_role_arn" {
  type        = string
  description = "The ARN of the base role to use for kube2iam"
}
