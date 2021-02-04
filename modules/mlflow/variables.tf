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

variable mlflow_def {
  type        = string
  description = "The resource definition for MLFlow"
  default = null //default is constructed dynmaically. See locals.tf
}

variable namespace {
  type        = string
  description = "The Namespace definition for MLFlow"
  default     = null //default is constructed dynmaically. See locals.tf
}


  


  
