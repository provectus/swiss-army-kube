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
  cluster_name = "sak-argocd-full"
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

  branch       = "feature/system-refactoring"
  owner        = "provectus"
  repository   = "swiss-army-kube"
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

module scaling {
  source       = "../../modules/scaling"
  cluster_name = module.kubernetes.cluster_name
  argocd       = module.argocd.state
}

module ingress {
  source       = "../../modules/ingress/nginx"
  cluster_name = module.kubernetes.cluster_name
  argocd       = module.argocd.state
}

module external_dns {
  source       = "../../modules/system/external-dns"
  cluster_name = module.kubernetes.cluster_name
  argocd       = module.argocd.state
  mainzoneid   = data.aws_route53_zone.this.zone_id
  hostedzones  = local.domain
  tags         = local.tags
}

module "external_secrets" {
  source         = "../../modules/system/external-secrets"
  cluster_output = module.kubernetes.this
  argocd         = module.argocd.state
  tags           = local.tags
}