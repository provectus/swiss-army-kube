variable "namespace" {
  type        = string
  default     = ""
  description = "A name of the existing namespace"
}

variable "namespace_name" {
  type        = string
  default     = "argocd"
  description = "A name of namespace for creating"
}

variable "chart_version" {
  type        = string
  description = "A Helm Chart version"
  default     = "2.11.0"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A tags for attaching to new created AWS resources"
}

variable "conf" {
  type        = map(string)
  description = "A custom configuration for deployment"
  default     = {}
}

variable "module_depends_on" {
  default     = []
  type        = list(any)
  description = "A list of explicit dependencies"
}

variable "branch" {
  type        = string
  default     = ""
  description = "A GitHub reference"
}

variable "repository" {
  type        = string
  default     = ""
  description = "A GitHub repository wich would be used for IaC needs"
}

variable "owner" {
  type        = string
  default     = ""
  description = "An owner of GitHub repository"
}

variable "cluster_name" {
  type        = string
  default     = null
  description = "A name of the Amazon EKS cluster"
}

variable "domains" {
  type        = list(string)
  default     = []
  description = "A list of domains to use for ingresses"
}

variable "vcs" {
  type        = string
  description = "An URI of VCS"
  default     = "https://github.com"
}

variable "vcs_token" {
  type        = string
  description = "Token for accessing private VCS"
  default     = ""
}

variable "path_prefix" {
  type        = string
  description = "A path inside a repository, it should contain a trailing slash"
}

variable "apps_dir" {
  type        = string
  description = "A folder for ArgoCD apps"
  default     = "apps"
}

variable "ingress_annotations" {
  type        = map(string)
  description = "A set of annotations for ArgoCD Ingress"
  default     = {}
}

variable "oidc" {
  type        = map(string)
  description = "A set of variables required for enabling OIDC"
  default = {
    pool   = null
    id     = null
    secret = null
  }
}

variable "project_name" {
  type        = string
  description = "A name of the ArgoCD project for deploying SAK"
  default     = "default"
}

variable "permissions_boundary" {
  type        = string
  description = "Permissions boundary ARN to use for IAM role"
  default     = ""
}
