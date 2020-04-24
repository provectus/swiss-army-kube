locals {
  env     = "pv"
  project = "EDUCATION"
  name    = "demo"
}

module "network" {
  source       = "../../modules/network"
  environment  = local.env
  project      = local.project
  cluster_name = local.name
}

module "kubernetes" {
  source = "../../modules/kubernetes"

  vpc_id  = module.network.vpc_id
  subnets = module.network.private_subnets

  environment     = local.env
  project         = local.project
  cluster_name    = local.name
  cluster_version = "1.15"
}

module "system" {
  module_depends_on = [module.network.vpc_id, module.kubernetes.cluster_name]
  source            = "../../modules/system"

  environment        = local.env
  project            = local.project
  cluster_name       = local.name
  domains            = ["demo.edu.provectus.io"]
  config_path        = "${path.module}/kubeconfig_${local.name}"
  cert_manager_email = "rgimadiev@provectus.com"
  cluster_oidc_url   = module.kubernetes.cluster_oidc_url
}

module "scaling" {
  source       = "../../modules/scaling"
  cluster_name = local.name
  #  cluster_oidc   = module.system.iam_openid_provider
}

module "argo" {
  source              = "../../modules/cicd/argo"
  cluster_name        = local.name
  iam_openid_provider = module.system.iam_openid_provider
  domains             = ["demo.edu.provectus.io"]
  environment         = local.env
  project             = local.project
}
