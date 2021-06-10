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
  source     = "github.com/provectus/sak-kubernetes?ref=hydrosphere"

  environment        = local.environment
  project            = local.project
  availability_zones = var.availability_zones
  cluster_name       = local.cluster_name
  vpc_id             = module.network.vpc_id
  subnets            = module.network.private_subnets
  domains            = local.domain
  //We use ASG group and taint with customer name
  customers                           = ["hydrosphere.io"]
  on_demand_customer_max_cluster_size = "10"
}

module "argocd" {
  depends_on = [module.network.vpc_id, module.kubernetes.cluster_name, data.aws_eks_cluster.cluster, data.aws_eks_cluster_auth.cluster]
  source     = "github.com/provectus/sak-argocd"

  branch       = var.argocd.branch
  owner        = var.argocd.owner
  repository   = var.argocd.repository
  cluster_name = module.kubernetes.cluster_name
  path_prefix  = "examples/hydrosphere/"
  //Private repository and credentials
  https_username = "exampleuser"
  https_password = "examplepass"
  repo_conf      = "- url: https://github.com/Hydrospheredata/hydro-serving"
  //
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
module "cert-manager" {
  depends_on = [module.argocd]

  source       = "github.com/provectus/sak-cert-manager"
  cluster_name = module.kubernetes.cluster_name
  vpc_id       = module.network.vpc_id
  argocd       = module.argocd.state
  email        = "example@provectus.com"
  zone_id      = module.external_dns.zone_id
  domains      = local.domain
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

module "scaling" {
  depends_on = [module.argocd]

  source       = "github.com/provectus/sak-scaling"
  cluster_name = module.kubernetes.cluster_name
  argocd       = module.argocd.state

}

module "nginx-ingress" {
  depends_on   = [module.argocd]
  source       = "github.com/provectus/sak-nginx"
  cluster_name = module.kubernetes.cluster_name
  argocd       = module.argocd.state
  conf         = {}
  tags         = local.tags
}
//Google auth for efk
module "oauth" {
  depends_on     = [module.argocd]
  source         = "github.com/provectus/sak-oauth"
  cluster_name   = module.kubernetes.cluster_name
  domains        = local.domain
  argocd         = module.argocd.state
  namespace_name = "oauth"
  client_id      = "googleclientid"
  client_secret  = "googleclientsecret"
  cookie_secret  = "OqRS8hOXD6ljqapm+zfl4g=="
  ingress_annotations = {
    "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    "kubernetes.io/ingress.class"              = "nginx"
    "kubernetes.io/tls-acme"                   = "true"
    "cert-manager.io/cluster-issuer"           = "letsencrypt-prod"
  }
}

module "prometheus" {
  depends_on              = [module.argocd]
  source                  = "github.com/provectus/sak-prometheus"
  cluster_name            = module.kubernetes.cluster_name
  argocd                  = module.argocd.state
  domains                 = local.domain
  grafana_google_auth     = true
  grafana_allowed_domains = "provectus.com"
  grafana_client_id       = "googleclientid"
  grafana_client_secret   = "googleclientsecret"
  conf = {
    "grafana.env.GF_USER_AUTO_ASSIGN_ORG_ROLE" = "EDITOR"
    "grafana.env.GF_USER_EDITORS_CAN_ADMIN"    = "true"
  }
}

module "efk" {
  depends_on   = [module.argocd]
  source       = "github.com/provectus/sak-efk"
  cluster_name = module.kubernetes.cluster_name
  argocd       = module.argocd.state
  domains      = local.domain
  ingress_annotations = {
    "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    "kubernetes.io/ingress.class"              = "nginx"
    "kubernetes.io/tls-acme"                   = "true"
    "cert-manager.io/cluster-issuer"           = "letsencrypt-prod"
    "nginx.ingress.kubernetes.io/auth-url"     = "https://oauth2.${local.domain[0]}/oauth2/auth"
    "nginx.ingress.kubernetes.io/auth-signin"  = "https://oauth2.${local.domain[0]}/oauth2/sign_in?rd=https://$host$request_uri"
  }
  kibana_conf = {}
  filebeat_conf = {
    "setup.kibana.host"                              = "https://kibana.${local.domain[0]}:443"
    "setup.dashboards.enabled"                       = "true"
    "setup.template.enabled"                         = "true"
    "setup.template.name"                            = "filebeat"
    "setup.template.pattern"                         = "filebeat-*"
    "setup.template.settings.index.number_of_shards" = "1"
    "setup.ilm.enabled"                              = "auto"
    "setup.ilm.check_exists"                         = "false"
    "setup.ilm.overwrite"                            = "true"
  }
}

module "hydrosphere" {
  depends_on    = [module.argocd]
  source        = "github.com/provectus/sak-hydrosphere"
  cluster_name  = module.kubernetes.cluster_name
  chart_version = "2.4.3"
  argocd        = module.argocd.state
  domains       = local.domain
  ingress_annotations = {
    "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    "kubernetes.io/ingress.class"              = "nginx"
    "kubernetes.io/tls-acme"                   = "true"
    "cert-manager.io/cluster-issuer"           = "letsencrypt-prod"
  }
}