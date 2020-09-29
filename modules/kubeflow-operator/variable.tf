variable domain {
  type        = string
  description = "A domain name that would be assigned to Kubeflow installation"
}

variable argocd {
  type        = map(string)
  description = "A set of variables for enabling ArgoCD"
  default = {
    namespace  = ""
    path       = ""
    repository = ""
    branch     = ""
  }
}

variable ingress_annotations {
  type        = map(string)
  description = "A set of annotations for Kubeflow Ingress"
  default     = {}
}
