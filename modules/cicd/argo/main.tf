data "aws_region" "current" {}

module "argo-cd" {
  source = "./modules/cd"

  domains = var.domains
}

module "argo-events" {
  source = "./modules/events"
}

module "argo-workflow" {
  module_depends_on = [module.argo-events.argo_events_namespace]
  source            = "./modules/workflow"

  environment           = var.environment
  project               = var.project
  cluster_name          = var.cluster_name
  cluster_oidc          = var.iam_openid_provider
  argo_events_namespace = module.argo-events.argo_events_namespace
}
