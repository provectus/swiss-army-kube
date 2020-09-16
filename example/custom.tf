module argocd {
  source            = "../modules/cicd/argo-cd"
  branch            = var.branch
  owner             = var.owner
  repository        = var.repository
  module_depends_on = [module.kubernetes]
}

module autoscaler {
  source            = "../modules/scaling"
  image_tag         = "v1.15.7"
  cluster_name      = module.kubernetes.cluster_name
  module_depends_on = [module.kubernetes]
}

variable branch {
  type        = string
  description = "describe your variable"
}

variable owner {
  type        = string
  description = "describe your variable"
}

variable repository {
  type        = string
  description = "describe your variable"
}
