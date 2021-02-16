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

variable profiles {
  type        = list
  description = "The profiles to be created"
}
  


  
