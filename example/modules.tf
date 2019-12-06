module "kubernetes" {
  source = "github.com/provectus/swiss-army-kube//modules/kubernetes?ref=hydrosphera"

  environment  = var.environment
  cluster_name = var.cluster_name
  aws_region      = var.aws_region
  vpc_id          = module.network.vpc_id
  private_subnets = module.network.private_subnets
  admin_arns      = var.admin_arns
  domain             = var.domain
  cert_manager_email = "dkharlamov@provectus.com"
  on_demand_max_cluster_size = "3"
  on_demand_desired_capacity = "2"
  on_demand_instance_type    = "c5.large"
  spot_max_cluster_size = "6"
  spot_desired_capacity = "2"
  spot_instance_type    = "c5.large"
  cluster_version = "1.14"  
}

module "network" {
  source = "github.com/provectus/swiss-army-kube//modules/network?ref=hydrosphera"

  availability_zones = var.availability_zones
  environment  = var.environment
  cluster_name = var.cluster_name
  network      = var.network 
}

module "system" {
  source = "github.com/provectus/swiss-army-kube//modules/system?ref=hydrosphera"

  environment  = var.environment
  cluster_name = var.cluster_name
  cluster_size = var.cluster_size
  domain       = var.domain
  config_path  = "${path.module}/kubeconfig_${var.cluster_name}"
}

module "nginx" {
  source = "github.com/provectus/swiss-army-kube//modules/ingress/nginx?ref=hydrosphera"

  #environment  = var.environment
  cluster_name = var.cluster_name
  config_path  = "${path.module}/kubeconfig_${var.cluster_name}"
}

module "prometheus" {
  source = "github.com/provectus/swiss-army-kube//modules/monitoring/prometheus?ref=hydrosphera"

  #environment  = var.environment
  cluster_name = var.cluster_name
  domain       = var.domain
  config_path  = "${path.module}/kubeconfig_${var.cluster_name}"
}

module "loki" {
  source = "github.com/provectus/swiss-army-kube//modules/logging/loki?ref=hydrosphera"

  #environment  = var.environment
  cluster_name = var.cluster_name
  domain       = var.domain
  config_path  = "${path.module}/kubeconfig_${var.cluster_name}"
}