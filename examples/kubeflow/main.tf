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

data "aws_region" "current" {}

locals {
  environment  = var.environment
  project      = var.project
  cluster_name = var.cluster_name
  domain       = ["${local.cluster_name}.${var.domain_name}"]
  cert_email   = "dkharlamov@provectus.com"
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
  source     = "github.com/provectus/sak-kubernetes"

  environment        = local.environment
  project            = local.project
  availability_zones = var.availability_zones
  cluster_name       = local.cluster_name
  domains            = local.domain
  vpc_id             = module.network.vpc_id
  subnets            = module.network.private_subnets
}

module "argocd" {
  depends_on = [module.network.vpc_id, module.kubernetes.cluster_name, data.aws_eks_cluster.cluster, data.aws_eks_cluster_auth.cluster]
  source     = "github.com/provectus/sak-argocd"

  branch        = var.argocd.branch
  owner         = var.argocd.owner
  repository    = var.argocd.repository
  cluster_name  = module.kubernetes.cluster_name
  path_prefix   = "examples/kubeflow/"
  chart_version = "3.11.1"

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
module "registry-mirror" { # Helps to avoid dockerhub limits
  depends_on   = [module.argocd]
  source       = "github.com/provectus/sak-incubator//registry-mirror"
  cluster_name = module.kubernetes.cluster_name
  argocd       = module.argocd.state
  storage      = "filesystem"
  domains      = local.domain

  conf = {}
  tags = local.tags
}

module "external_dns" {
  depends_on = [module.argocd]

  source       = "github.com/provectus/sak-external-dns"
  cluster_name = module.kubernetes.cluster_name
  argocd       = module.argocd.state
  mainzoneid   = data.aws_route53_zone.this.zone_id
  hostedzones  = local.domain
  tags         = local.tags
}

module "cert-manager" {
  depends_on = [module.argocd]

  source       = "github.com/provectus/sak-cert-manager"
  cluster_name = module.kubernetes.cluster_name
  vpc_id       = module.network.vpc_id
  argocd       = module.argocd.state
  email        = local.cert_email
  zone_id      = module.external_dns.zone_id
  domains      = local.domain
}

module "scaling" {
  depends_on = [module.argocd]

  source       = "github.com/provectus/sak-scaling"
  cluster_name = module.kubernetes.cluster_name
  argocd       = module.argocd.state

}

module "clusterwide" {
  depends_on = [module.argocd]
  source     = "terraform-aws-modules/acm/aws"
  version    = "~> v2.12"

  domain_name = "*.${local.domain[0]}"
  subject_alternative_names = [
    local.domain[0]
  ]
  zone_id              = module.external_dns.zone_id
  validate_certificate = true #Disable if used private DNS and validate it manually
  wait_for_validation  = false
  tags                 = local.tags
}

module "nginx-ingress" {
  depends_on   = [module.clusterwide]
  source       = "github.com/provectus/sak-nginx"
  cluster_name = module.kubernetes.cluster_name
  argocd       = module.argocd.state
  conf         = {}
  tags         = local.tags
}

module "internal-nginx-ingress" {
  depends_on     = [module.argocd]
  source         = "github.com/provectus/sak-nginx"
  namespace_name = "internal-ingress"
  internal       = true
  cluster_name   = module.kubernetes.cluster_name
  argocd         = module.argocd.state
  conf = {
    "controller.service.internal.enabled"                                                        = true
    "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal" = "0.0.0.0"
    "controller.ingressClass"                                                                    = "internal"
  }
  tags = local.tags
}

module "prometheus" {
  depends_on = [module.argocd]
  #  source         = "github.com/provectus/sak-prometheus"
  source         = "../../../sak-prometheus"
  cluster_name   = module.kubernetes.cluster_name
  argocd         = module.argocd.state
  domains        = local.domain
  thanos_enabled = false
}

module "cognito" {
  source            = "github.com/provectus/sak-cognito"
  cluster_name      = module.kubernetes.cluster_name
  domain            = "${local.cluster_name}.${var.domain_name}"
  zone_id           = module.external_dns.zone_id
  mfa_configuration = "OPTIONAL"
  acm_arn           = module.clusterwide.this_acm_certificate_arn
  tags              = local.tags
}

module "external_secrets" {
  depends_on       = [module.argocd]
  source           = "github.com/provectus/sak-external-secrets"
  cluster_oidc_url = module.kubernetes.cluster_oidc_url
  cluster_name     = module.kubernetes.cluster_name
  argocd           = module.argocd.state
  tags             = local.tags
}



module "kubeflow" {
  source = "git::https://github.com/provectus/swiss-army-kube.git//modules/kubeflow-operator?ref=feature/argocd"
  ingress_annotations = {
    "kubernetes.io/ingress.class"               = "alb"
    "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
    "alb.ingress.kubernetes.io/certificate-arn" = module.clusterwide.this_acm_certificate_arn
    "alb.ingress.kubernetes.io/auth-type"       = "cognito"
    "alb.ingress.kubernetes.io/auth-idp-cognito" = jsonencode({
      "UserPoolArn"      = module.cognito.pool_arn
      "UserPoolClientId" = aws_cognito_user_pool_client.kubeflow.id
      "UserPoolDomain"   = module.cognito.domain
    })
    "alb.ingress.kubernetes.io/listen-ports" = jsonencode(
      [{ "HTTPS" = 443 }]
    )
  }
  domain = "kubeflow.${local.domain[0]}"
  argocd = module.argocd.state
}

resource "aws_cognito_user_pool_client" "kubeflow" {
  name                                 = "kubeflow"
  user_pool_id                         = module.cognito.pool_id
  callback_urls                        = ["https://kubeflow.${local.domain[0]}/oauth2/idpresponse"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["email", "openid", "profile", "aws.cognito.signin.user.admin"]
  allowed_oauth_flows                  = ["code"]
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "argocd" {
  name                                 = "argocd"
  user_pool_id                         = module.cognito.pool_id
  callback_urls                        = ["https://argocd.${local.domain[0]}/auth/callback"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["openid", "profile", "email"]
  allowed_oauth_flows                  = ["code"]
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

### Optional step of populating Cognito User Pool
### will be executed locally, so aws-cli should present on the local machine
### this is an inelegant way for managing users, suitable only for demo purpose

resource "aws_cognito_user_group" "this" {
  for_each = toset(distinct(values(
    {
      for k, v in var.cognito_users :
      k => lookup(v, "group", "read-only")
    }
  )))
  name         = each.value
  user_pool_id = module.cognito.pool_id
}

resource "null_resource" "cognito_users" {
  depends_on = [module.cognito.pool_id, aws_cognito_user_group.this]
  for_each = {
    for k, v in var.cognito_users :
    format("%s:%s:%s", data.aws_region.current.name, module.cognito.pool_id, v.username) => v

  }
  provisioner "local-exec" {
    command = "aws --region ${element(split(":", each.key), 0)} cognito-idp admin-create-user --user-pool-id ${element(split(":", each.key), 1)} --username ${element(split(":", each.key), 2)} --user-attributes Name=email,Value=${each.value.email}"
  }
  provisioner "local-exec" {
    command = "aws --region ${element(split(":", each.key), 0)} cognito-idp admin-add-user-to-group --user-pool-id ${element(split(":", each.key), 1)} --username ${element(split(":", each.key), 2)} --group-name ${lookup(each.value, "group", "read-only")}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "aws --region ${element(split(":", each.key), 0)} cognito-idp admin-delete-user --user-pool-id ${element(split(":", each.key), 1)} --username ${element(split(":", each.key), 2)}"
  }
}
