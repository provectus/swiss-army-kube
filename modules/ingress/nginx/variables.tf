variable namespace {
  type        = string
  default     = ""
  description = "A name of the existing namespace"
}

variable namespace_name {
  type        = string
  default     = "ingress-system"
  description = "A name of namespace for creating"
}

variable module_depends_on {
  default     = []
  description = "A list of explicit dependencies for the module"
}

variable cluster_name {
  type        = string
  description = "The name of the cluster the charts will be deployed to"
}

variable aws_private {
  type        = bool
  description = "Set true or false to use private or public infrastructure"
  default     = false
}

variable argocd {
  type        = map(string)
  description = "A set of values for enabling deployment through ArgoCD"
  default     = {}
}

variable conf {
  default     = {}
  description = "A set of parameters to pass to Nginx Ingress Controller chart"
}
