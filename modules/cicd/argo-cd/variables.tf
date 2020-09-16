variable chart_version {
  type        = string
  description = "An ArgoCD Helm Chart version"
  default     = "2.7.0"
}

variable namespace {
  type        = string
  description = "A target namespace for ArgoCD deployment"
  default     = "argocd"
}


variable conf {
  type        = map(string)
  description = "A custom configuration for ArgoCD deployment"
  default     = {}
}

variable module_depends_on {
  type        = list
  default     = []
  description = "A dependency list"
}


variable branch {
  type        = string
  description = "describe your variable"
}

variable repository {
  type        = string
  description = "describe your variable"
}

variable owner {
  type        = string
  description = "describe your variable"
}
