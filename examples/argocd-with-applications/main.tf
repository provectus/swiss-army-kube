data aws_eks_cluster cluster {
  name = module.kubernetes.cluster_name
}

data aws_eks_cluster_auth cluster {
  name = module.kubernetes.cluster_name
}

data aws_route53_zone this {
  # name         = "edu.provectus.io."
  zone_id      = "" # put zoneid here
  private_zone = false
}

locals {
  environment  = "dev"
  project      = "EDUCATION"
  cluster_name = "" # set cluster name here
  domain       = ["${local.cluster_name}.edu.provectus.io"]
  tags = {
    environment = local.environment
    project     = local.project
  }
}

module network {
  source = "../../modules/network"

  availability_zones = ["eu-north-1a", "eu-north-1b"]
  environment        = local.environment
  project            = local.project
  cluster_name       = local.cluster_name
  network            = 10
}
#
module kubernetes {
  depends_on = [module.network]
  source     = "../../modules/kubernetes"

  environment        = local.environment
  project            = local.project
  availability_zones = ["eu-north-1a", "eu-north-1b"]
  cluster_name       = local.cluster_name
  vpc_id             = module.network.vpc_id
  subnets            = module.network.private_subnets

  on_demand_gpu_instance_type = ["g4dn.xlarge"]
}

module argocd {
  depends_on = [module.network.vpc_id, module.kubernetes.cluster_name]
  source     = "../../modules/cicd/argo/modules/cd"

  branch       = "BRANCH"
  owner        = "OWNER"
  repository   = "REPOSITORY"
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


module external_dns {
  depends_on   = [module.argocd, module.network.vpc_id, module.kubernetes.cluster_name]

  source       = "../../modules/system/external-dns"
  cluster_name = module.kubernetes.cluster_name
  argocd       = module.argocd.state
  mainzoneid   = data.aws_route53_zone.this.zone_id
  hostedzones  = local.domain
  tags         = local.tags
}

module scaling {
  depends_on   = [module.argocd, module.network.vpc_id, module.kubernetes.cluster_name]

  source       = "../../modules/scaling"
  cluster_name = module.kubernetes.cluster_name
  argocd       = module.argocd.state
}


module external_secrets {
  depends_on     = [module.kubernetes, module.argocd]
  source         = "../../modules/system/external-secrets"
  cluster_output = module.kubernetes.cluster_output
  argocd         = module.argocd.state
  tags           = local.tags
}

# module clusterwide {
#   depends_on = [module.external_dns]
#   source  = "terraform-aws-modules/acm/aws"
#   version = "~> v2.12"
#
#   domain_name          = local.domain[0]
#   subject_alternative_names = [
#     "*.${local.domain[0]}"
#   ]
#   zone_id              = module.external_dns.zone_id
#   validate_certificate = true
#   wait_for_validation  = false
#   tags                 = local.tags
# }
#
# module ingress {
#   depends_on   = [module.kubernetes]
#   source       = "../../modules/ingress/nginx"
#   cluster_name = module.kubernetes.cluster_name
#   argocd       = module.argocd.state
#   conf = {
#     "controller.service.targetPorts.http"                                                                = "http"
#     "controller.service.targetPorts.https"                                                               = "http"
#     "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"         = module.clusterwide.this_acm_certificate_arn
#     "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol" = "http"
#     "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-ports"        = "https"
#   }
#   tags                 = local.tags
# }

# module monitoring {
#   module_depends_on = [module.argocd.state.path, module.kubernetes.cluster_name]
#   source            = "../../modules/monitoring/prometheus"
#   cluster_name      = module.kubernetes.cluster_name
#   argocd            = module.argocd.state
#   domains           = local.domain
# }
