data "aws_eks_cluster" "cluster" {
  name = module.kubernetes.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.kubernetes.cluster_name
}

locals {
  environment  = var.environment
  project      = var.project
  cluster_name = var.cluster_name
  domain       = ["${local.cluster_name}.${var.domain_name}"]
  tags = {
    environment = local.environment
    project     = local.project
  }
}

module "network" {
  source = "../../modules/network"

  availability_zones = var.availability_zones
  environment        = local.environment
  project            = local.project
  cluster_name       = local.cluster_name
  network            = 10
}
#
module "kubernetes" {
  depends_on = [module.network]
  source     = "../../modules/kubernetes"

  environment        = local.environment
  project            = local.project
  availability_zones = var.availability_zones
  cluster_name       = local.cluster_name
  vpc_id             = module.network.vpc_id
  subnets            = module.network.private_subnets

  on_demand_gpu_instance_type = ["g4dn.xlarge"]
}

module "argocd" {
  depends_on = [module.network.vpc_id, module.kubernetes.cluster_name]
  source     = "../../modules/cicd/argo/modules/cd"

  branch       = var.argocd.branch
  owner        = var.argocd.owner
  repository   = var.argocd.repository
  cluster_name = module.kubernetes.cluster_name
  path_prefix  = "examples/argocd-with-applications/"

  domains = local.domain
  ingress_annotations = {
    "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    "kubernetes.io/ingress.class"              = "nginx"
  }
  conf = {
    "server.service.type"     = "ClusterIP"
    "server.ingress.paths[0]" = "/"
  }
}

module "argo_events" {
  source       = "../../modules/cicd/argo/modules/events"
  cluster_name = module.kubernetes.cluster_name
  argocd       = module.argocd.state
  tags         = local.tags
}
