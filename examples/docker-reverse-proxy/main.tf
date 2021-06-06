data "aws_eks_cluster" "cluster" {
  name = module.kubernetes.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.kubernetes.cluster_name
}

data "aws_route53_zone" "this" {
  # name         = "edu.provectus.io."
  zone_id      = var.zone_id
  private_zone = false
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
  source = "github.com/provectus/sak-vpc" #By default ?ref=HEAD 

  availability_zones = var.availability_zones
  environment        = local.environment
  project            = local.project
  cluster_name       = local.cluster_name
  network            = 10
}

module "kubernetes" {
  depends_on = [module.network]
  source     = "github.com/provectus/sak-kubernetes?ref=registry"

  environment        = local.environment
  project            = local.project
  availability_zones = var.availability_zones
  cluster_name       = local.cluster_name
  domains            = local.domain
  cluster_version    = "1.19"
  vpc_id             = module.network.vpc_id
  subnets            = module.network.private_subnets
}

module "argocd" {
  depends_on = [module.network.vpc_id, module.kubernetes.cluster_name, data.aws_eks_cluster.cluster, data.aws_eks_cluster_auth.cluster]
  source     = "github.com/provectus/sak-argocd"

  branch       = var.argocd.branch
  owner        = var.argocd.owner
  repository   = var.argocd.repository
  cluster_name = module.kubernetes.cluster_name
  path_prefix  = "examples/docker-reverse-proxy/"

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

#Apps
module "external_dns" {
  depends_on = [module.argocd]

  source       = "github.com/provectus/sak-external-dns"
  cluster_name = module.kubernetes.cluster_name
  argocd       = module.argocd.state
  mainzoneid   = data.aws_route53_zone.this.zone_id
  hostedzones  = local.domain
  tags         = local.tags
}

module "scaling" {
  depends_on = [module.argocd]

  source       = "github.com/provectus/sak-scaling"
  cluster_name = module.kubernetes.cluster_name
  argocd       = module.argocd.state

}

module "cert-manager" {
  depends_on   = [module.argocd]

  source       = "github.com/provectus/sak-cert-manager"
  cluster_name = module.kubernetes.cluster_name
  vpc_id       = module.network.vpc_id
  argocd       = module.argocd.state
  email        = "dkharlamov@provectus.com"
  zone_id      = module.external_dns.zone_id
  domains      = local.domain
}

module "nginx-ingress" {
  depends_on   = [module.argocd]
  source       = "github.com/provectus/sak-nginx"
  cluster_name = module.kubernetes.cluster_name
  argocd       = module.argocd.state
  conf = {}
  tags = local.tags
}

module "internal-nginx-ingress" {
  depends_on     = [module.argocd]
  source         = "github.com/provectus/sak-nginx"
  namespace_name = "internal-ingress"
  internal       = true
  cluster_name   = module.kubernetes.cluster_name
  argocd         = module.argocd.state
  conf           = {
    "controller.service.internal.enabled"                                                        = true
    "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal" = "0.0.0.0"
    "controller.ingressClass"                                                                    = "internal"
  }
  tags = local.tags
}

module "registry-mirror" {
  depends_on   = [module.argocd]
  source       = "github.com/provectus/sak-incubator//registry-mirror"
  cluster_name = module.kubernetes.cluster_name
  argocd       = module.argocd.state
  storage      = "s3"
  domains      = local.domain

  conf = {}
  tags = local.tags
}
