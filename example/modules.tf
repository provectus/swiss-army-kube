module "kubernetes" {
  source = "../modules/kubernetes"

  environment                = var.environment
  project                    = var.project
  cluster_name               = var.cluster_name
  vpc_id                     = module.network.vpc_id
  subnets                    = module.network.private_subnets
  admin_arns                 = var.admin_arns
  on_demand_max_cluster_size = var.on_demand_max_cluster_size
  on_demand_min_cluster_size = var.on_demand_min_cluster_size
  on_demand_desired_capacity = var.on_demand_desired_capacity
  on_demand_instance_type    = var.on_demand_instance_type
  spot_max_cluster_size      = var.spot_max_cluster_size
  spot_min_cluster_size      = var.spot_min_cluster_size
  spot_desired_capacity      = var.spot_desired_capacity
  spot_instance_type         = var.spot_instance_type
  cluster_version            = var.cluster_version
}

module "network" {
  source = "../modules/network"

  availability_zones = var.availability_zones
  environment        = var.environment
  project            = var.project
  cluster_name       = var.cluster_name
  network            = var.network
}

module "system" {
  module_depends_on = [module.network.vpc_id, module.kubernetes.cluster_name]
  source            = "../modules/system"

  environment        = var.environment
  project            = var.project
  cluster_name       = var.cluster_name
  vpc_id             = module.network.vpc_id
  aws_private        = var.aws_private
  domains            = var.domains
  mainzoneid         = var.mainzoneid
  config_path        = "${path.module}/kubeconfig_${var.cluster_name}"
  cert_manager_email = var.cert_manager_email
  cluster_oidc_url   = module.kubernetes.cluster_oidc_url
}

module "scaling" {
  source       = "../modules/scaling"
  cluster_name = var.cluster_name
}

# Ingress
module "nginx" {
  module_depends_on = [module.system.cert-manager]
  source            = "../modules/ingress/nginx"

  cluster_name = var.cluster_name
  aws_private  = var.aws_private
  domains      = var.domains
  config_path  = "${path.module}/kubeconfig_${var.cluster_name}"

  #Need oauth2-proxy github auth? Use id and secret in base64
  github-auth          = var.github-auth
  github-client-id     = var.github-client-id
  github-org           = var.github-org
  github-client-secret = var.github-client-secret
  cookie-secret        = var.cookie-secret
}
//
//module "kubeflow" {
//  source       = "../modules/kubeflow"
//  vpc          = module.network.vpc
//  cluster_name = module.kubernetes.cluster_name
//  cluster      = module.kubernetes.this
//  artifacts    = module.argo-artifacts.artifacts
//}
//module "efs" {
//  source = "../modules/storage/efs"
//  vpc          = module.network.vpc
//  cluster_name = module.kubernetes.cluster_name
//}
//
//#ARGO CD
//module "argo-cd" {
//  module_depends_on = [module.system.cert-manager,module.nginx.nginx-ingress]
//  source            = "../modules/cicd/argo-cd"
//
//  domains = var.domains
//}
//
//module "argo-artifacts" {
//  module_depends_on = [module.system.cert-manager,module.argo-events.argo_events_namespace,module.nginx.nginx-ingress]
//  source            = "../modules/cicd/argo-artifacts"
//
//  aws_region            = var.aws_region
//  cluster_name          = var.cluster_name
//  environment           = var.environment
//  project               = var.project
//  argo_events_namespace = module.argo-events.argo_events_namespace
//}
//
//module "argo-events" {
//  module_depends_on = [module.system.cert-manager,module.nginx.nginx-ingress]
//  source            = "../modules/cicd/argo-events"
//}
//
//module "argo-workflow" {
//  module_depends_on = [module.system.cert-manager,module.nginx.nginx-ingress]
//  source            = "../modules/cicd/argo-workflow"
//
//  aws_region    = var.aws_region
//  aws_s3_bucket = module.argo-artifacts.aws_s3_bucket
//}
