variable "namespace" {
  type        = string
  default     = ""
  description = "A name of the existing namespace"
}

variable "namespace_name" {
  type        = string
  default     = "ingress-system"
  description = "A name of namespace for creating"
}

variable "domains" {
  description = "domain name for ingress"
  default     = []
}

variable "config_path" {
  description = "location of the kubeconfig file"
  default     = "~/.kube/config"
}

variable "github-auth" {
  description = "Trigger for enable or disable deploy oauth2-proxy"
  default     = false
}

variable "github-client-id" {
  default     = ""
  description = "Client id for auth github (create it https://github.com/settings/applications/new)"
}

variable "github-client-secret" {
  default     = ""
  description = "Client secrets"

}

variable "module_depends_on" {
  default     = []
  type        = list(any)
  description = "A list of explicit dependencies"
}

variable "cluster_name" {
  type        = string
  default     = null
  description = "A name of the Amazon EKS cluster"
}

variable "chart_version" {
  type        = string
  description = "A Helm Chart version"
  default     = "2.16.0"
}

variable "aws_private" {
  type        = bool
  description = "Set true or false to use private or public infrastructure"
  default     = false
}


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

variable "conf" {
  type        = map(string)
  description = "A custom configuration for deployment"
  default     = {}
}

variable "google-cookie-secret" {
  default     = ""
  description = "random_string make gen command python -c 'import os,base64; print base64.b64encode(os.urandom(16))'"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A tags for attaching to new created AWS resources"
}
