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
  source = "github.com/provectus/sak-vpc?ref=master"

  availability_zones = var.availability_zones
  environment        = local.environment
  project            = local.project
  cluster_name       = local.cluster_name
  network            = 10
}

module "kubernetes" {
  depends_on = [module.network]
  source     = "github.com/provectus/sak-kubernetes?ref=master"

  environment        = local.environment
  project            = local.project
  availability_zones = var.availability_zones
  cluster_name       = local.cluster_name
  domains            = local.domain
  vpc_id             = module.network.vpc_id
  subnets            = module.network.private_subnets
  cluster_version    = "1.21"

  on_demand_common_override_instance_types     = ["m5.large"]
  on_demand_gpu_resource_count                 = 0
  on_demand_cpu_percentage_above_base_capacity = "100"

  admin_arns = [
    {
      userarn  = "arn:aws:iam::245582572290:user/dlazarenko"
      username = "dlazarenko"
      groups   = ["system:masters"]
    }
  ]
}

module "argocd" {
  depends_on   = [module.network.vpc_id, module.kubernetes.cluster_name, data.aws_eks_cluster.cluster, data.aws_eks_cluster_auth.cluster]
  source       = "github.com/provectus/sak-argocd?ref=master"
  branch       = var.argocd.branch
  owner        = var.argocd.owner
  repository   = var.argocd.repository
  cluster_name = module.kubernetes.cluster_name
  path_prefix  = "examples/check_modules/"

  domains = local.domain
  ingress_annotations = {
    "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    "cert-manager.io/cluster-issuer"           = "letsencrypt-prod"
  }
  conf = {
    "server.service.type"             = "ClusterIP"
    "server.ingress.ingressClassName" = "nginx"
    "server.ingress.paths[0]"         = "/"
  }
}

module "external_dns" {
  depends_on   = [module.argocd]
  source       = "github.com/provectus/sak-external-dns?ref=master"
  cluster_name = module.kubernetes.cluster_name
  argocd       = module.argocd.state
  mainzoneid   = data.aws_route53_zone.this.zone_id
  hostedzones  = local.domain
  tags         = local.tags
}

module "cert-manager" {
  depends_on = [module.argocd]

  source       = "github.com/provectus/sak-cert-manager?ref=master"
  cluster_name = module.kubernetes.cluster_name
  vpc_id       = module.network.vpc_id
  argocd       = module.argocd.state
  email        = "dlazarenko@provectus.com"
  zone_id      = module.external_dns.zone_id
  domains      = local.domain
}

module "nginx-ingress" {
  depends_on   = [module.cert-manager]
  source       = "github.com/provectus/sak-nginx?ref=master"
  cluster_name = module.kubernetes.cluster_name
  argocd       = module.argocd.state
  conf         = {}
  tags         = local.tags
}
