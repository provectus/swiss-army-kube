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

variable repository {
  type        = string
  description = "The repository from which to roll out the Kubeflow manifests"
  default     = "https://github.com/kubeflow/manifests"
}

variable ref {
  type        = string
  description = "The reference (commit/branch/tag) from which to roll out the Kubeflow manifests"
  default     = "v1.2-branch"
}

variable namespace {
  type        = string
  description = "The Namespace resource definition"
  default     = null //default is constructed dynmaically. See locals.tf
}


variable ingress {
  type        = string
  description = "The Ingress resource definition"
  default = null //default is constructed dynmaically. See locals.tf
}

variable issuer {
  type        = string
  description = "The Issuer resource definition"
  default = null //default is constructed dynmaically. See locals.tf
}

variable kfdef {
  type        = string
  description = "The KfDef resouce definition"
  default     = null //default is constructed dynmaically. See locals.tf
}


  


  
