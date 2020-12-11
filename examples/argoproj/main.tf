data aws_eks_cluster cluster {
  name = module.kubernetes.cluster_name
}

data aws_eks_cluster_auth cluster {
  name = module.kubernetes.cluster_name
}

data aws_route53_zone this {
  name         = "edu.provectus.io."
  private_zone = false
}

locals {
  environment  = "dev"
  project      = "EDUCATION"
  cluster_name = "sak-argoproj"
  domain       = ["${local.cluster_name}.edu.provectus.io"]
  tags = {
    environment = local.environment
    project     = local.project
  }
}

module network {
  source = "../../modules/network"

  availability_zones = ["us-west-2a", "us-west-2b"]
  environment        = local.environment
  project            = local.project
  cluster_name       = local.cluster_name
  network            = 10
}

module kubernetes {
  source = "../../modules/kubernetes"

  environment        = local.environment
  project            = local.project
  availability_zones = ["us-west-2a", "us-west-2b"]
  cluster_name       = local.cluster_name
  vpc_id             = module.network.vpc_id
  subnets            = module.network.private_subnets
}

module argocd {
  module_depends_on = [module.network.vpc_id, module.kubernetes.cluster_name]
  source            = "../../modules/cicd/argo/modules/cd"

  branch       = "feature/argo-events"
  owner        = "provectus"
  repository   = "swiss-army-kube"
  cluster_name = module.kubernetes.cluster_name
  path_prefix  = "examples/argoproj/"

  domains = local.domain
  conf = {
    "server.service.type"    = "ClusterIP"
    "server.ingress.enabled" = "false"
  }

  tags = local.tags
}

module argo_events {
  source       = "../../modules/cicd/argo/modules/events"
  cluster_name = module.kubernetes.cluster_name
  argocd       = module.argocd.state
  tags         = local.tags
}
