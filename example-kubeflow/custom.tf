module acm {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"

  domain_name               = var.domains[0]
  subject_alternative_names = ["*.${var.domains[0]}"]
  zone_id                   = module.external_dns.zone_id
  validate_certificate      = var.aws_private == "false" ? true : false
  tags                      = local.tags
}

module argocd {
  source        = "../modules/cicd/argo-cd"
  branch        = var.branch
  owner         = var.owner
  repository    = var.repository
  cluster_name  = module.kubernetes.cluster_name
  domains       = var.domains
  chart_version = "2.7.4"
  argocd        = module.argocd.state
}

module kubeflow {
  source = "../modules/kubeflow-operator"
  ingress_annotations = {
    "kubernetes.io/ingress.class"         = "alb"
    "alb.ingress.kubernetes.io/scheme"    = "internet-facing"
    "alb.ingress.kubernetes.io/auth-type" = "cognito"
    "alb.ingress.kubernetes.io/auth-idp-cognito" = jsonencode({
      "UserPoolArn"      = module.cognito.pool_arn
      "UserPoolClientId" = aws_cognito_user_pool_client.kubeflow.id
      "UserPoolDomain"   = module.cognito.domain
    })
    "alb.ingress.kubernetes.io/certificate-arn" = module.acm.this_acm_certificate_arn
    "alb.ingress.kubernetes.io/listen-ports" = jsonencode(
      [{ "HTTPS" = 443 }]
    )
  }
  domain = "kubeflow.${var.domains[0]}"
  argocd = module.argocd.state
}

module cluster_autoscaler {
  source            = "../modules/system/cluster-autoscaler"
  image_tag         = "v1.15.7"
  cluster_name      = module.kubernetes.cluster_name
  module_depends_on = [module.kubernetes]
  argocd            = module.argocd.state
}

module cert_manager {
  module_depends_on = [module.kubernetes]
  source            = "../modules/system/cert-manager"
  cluster_name      = module.kubernetes.cluster_name
  domains           = var.domains
  vpc_id            = module.network.vpc_id
  environment       = var.environment
  project           = var.project
  zone_id           = module.external_dns.zone_id
  email             = var.cert_manager_email
  argocd            = module.argocd.state
}

module alb_ingress {
  module_depends_on = [module.kubernetes]
  source            = "../modules/ingress/aws-alb"
  cluster_name      = module.kubernetes.cluster_name
  domains           = var.domains
  vpc_id            = module.network.vpc_id
  certificates_arns = [module.acm.this_acm_certificate_arn]
  argocd            = module.argocd.state
}

module external_dns {
  source       = "../modules/system/external-dns"
  cluster_name = module.kubernetes.cluster_name
  environment  = var.environment
  project      = var.project
  vpc_id       = module.network.vpc_id
  aws_private  = var.aws_private
  domains      = var.domains
  mainzoneid   = var.mainzoneid
  argocd       = module.argocd.state
}

module cognito {
  source  = "../modules/cognito"
  domain  = var.domains[0]
  zone_id = var.zone_id
}

resource aws_cognito_user_pool_client kubeflow {
  name                                 = "kubeflow"
  user_pool_id                         = module.cognito.pool_id
  callback_urls                        = ["https://kubeflow.${var.domains[0]}/oauth2/idpresponse"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["email", "openid", "profile", "aws.cognito.signin.user.admin"]
  allowed_oauth_flows                  = ["code"]
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource aws_cognito_user_pool_client argocd {
  name                                 = "argocd"
  user_pool_id                         = module.cognito.pool_id
  callback_urls                        = ["https://argocd.${var.domains[0]}/auth/callback"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["openid", "profile", "email", "groups"]
  allowed_oauth_flows                  = ["code"]
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}
