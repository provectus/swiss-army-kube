module argocd {
  source       = "../modules/cicd/argo-cd"
  branch       = var.branch
  owner        = var.owner
  repository   = var.repository
  cluster_name = module.kubernetes.cluster_name
  domains      = var.domains
}

module cluster_autoscaler {
  source            = "../modules/system/cluster-autoscaler"
  image_tag         = "v1.15.7"
  cluster_name      = module.kubernetes.cluster_name
  module_depends_on = [module.kubernetes]
}

# module cert_manager {
#   source       = "../modules/system/cert-manager"
#   cluster_name = module.kubernetes.cluster_name
# }

# module external_secrets {
#   source       = "../modules/system/external-secrets"
#   cluster_name = module.kubernetes.cluster_name
# }

module external_dns {
  source       = "../modules/system/external-dns"
  cluster_name = module.kubernetes.cluster_name
  environment  = var.environment
  project      = var.project
  vpc_id       = module.network.vpc_id
  aws_private  = var.aws_private
  domains      = var.domains
  mainzoneid   = var.mainzoneid
}
