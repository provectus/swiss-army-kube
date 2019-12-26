module "kubernetes" {
  source = "github.com/provectus/swiss-army-kube//modules/kubernetes?ref=master"

  environment                = var.environment
  project                    = var.project
  cluster_name               = var.cluster_name
  aws_region                 = var.aws_region
  vpc_id                     = module.network.vpc_id
  private_subnets            = module.network.private_subnets
  admin_arns                 = var.admin_arns
  domain                     = var.domain
  cert_manager_email         = var.cert_manager_email
  on_demand_max_cluster_size = var.on_demand_max_cluster_size
  on_demand_desired_capacity = var.on_demand_desired_capacity
  on_demand_instance_type    = var.on_demand_instance_type
  spot_max_cluster_size      = var.spot_max_cluster_size
  spot_desired_capacity      = var.spot_desired_capacity
  spot_instance_type         = var.spot_instance_type
  cluster_version            = var.cluster_version
}

module "network" {
  source = "github.com/provectus/swiss-army-kube//modules/network?ref=master"

  availability_zones = var.availability_zones
  environment        = var.environment
  project            = var.project
  cluster_name       = var.cluster_name
  network            = var.network
}

module "system" {
  module_depends_on = [module.network.vpc_id, module.kubernetes.cluster_name]
  source            = "github.com/provectus/swiss-army-kube//modules/system?ref=master"

  environment         = var.environment
  project             = var.project
  cluster_name        = var.cluster_name
  domain              = var.domain
  config_path         = "${path.module}/kubeconfig_${var.cluster_name}"
  cert_manager_email  = var.cert_manager_email
  cert_manager_zoneid = var.cert_manager_zoneid
  cluster_oidc_url    = module.kubernetes.cluster_oidc_url
}

# Ingress
module "nginx" {
  module_depends_on = [module.system.kubernetes_service_account]
  source = "../modules/ingress/nginx"

  cluster_name = var.cluster_name
  domain       = var.domain
  config_path  = "${path.module}/kubeconfig_${var.cluster_name}"

  #Need oauth2-proxy github auth? Use id and secret in base64
  github-auth          = var.github-auth
  github-client-id     = var.github-client-id
  github-org           = var.github-org
  github-client-secret = var.github-client-secret
  cookie-secret        = var.cookie-secret
}

# Monitoring
module "prometheus" {
  module_depends_on = [module.system.kubernetes_service_account]
  source            = "github.com/provectus/swiss-army-kube//modules/monitoring/prometheus?ref=master"

  cluster_name = var.cluster_name
  domain       = var.domain
  config_path  = "${path.module}/kubeconfig_${var.cluster_name}"
}

# Logging
module "loki" {
  module_depends_on = [module.system.kubernetes_service_account]
  source            = "github.com/provectus/swiss-army-kube//modules/logging/loki?ref=master"

  cluster_name = var.cluster_name
  domain       = var.domain
  config_path  = "${path.module}/kubeconfig_${var.cluster_name}"
}

#module "efk" {
#  module_depends_on = [module.system.kubernetes_service_account]
#  source            = "github.com/provectus/swiss-army-kube//modules/logging/efk?ref=master"
#  cluster_name     = var.cluster_name
#  domain           = var.domain
#  config_path      = "${path.module}/kubeconfig_${var.cluster_name}"
#  elasticDataSize  = var.elasticDataSize
#}

#ARGO CD
module "argo-cd" {
  module_depends_on = [module.system.kubernetes_service_account]
  source            = "github.com/provectus/swiss-army-kube//modules/cicd/argo-cd?ref=master"

  domain = var.domain
}

module "argo-artifacts" {
  module_depends_on = [module.system.kubernetes_service_account, module.argo-events.argo_events_namespace]
  source            = "github.com/provectus/swiss-army-kube//modules/cicd/argo-artifacts?ref=master"

  aws_region            = var.aws_region
  cluster_name          = var.cluster_name
  environment           = var.environment
  project               = var.project
  argo_events_namespace = module.argo-events.argo_events_namespace
}

module "argo-events" {
  module_depends_on = [module.system.kubernetes_service_account]
  source            = "github.com/provectus/swiss-army-kube//modules/cicd/argo-events?ref=master"
}

module "argo-workflow" {
  module_depends_on = [module.system.kubernetes_service_account, module.system.cert-manager]
  source            = "github.com/provectus/swiss-army-kube//modules/cicd/argo-workflow?ref=master"

  aws_region    = var.aws_region
  aws_s3_bucket = module.argo-artifacts.aws_s3_bucket
}
