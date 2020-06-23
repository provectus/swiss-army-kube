data "aws_region" "current" {}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

module "argo-cd" {
  source    = "./modules/cd"
  domains   = var.domains
  namespace = var.namespace
}

module "argo-events" {
  source    = "./modules/events"
  namespace = var.namespace
}

module "argo-workflow" {
  module_depends_on = [module.argo-events.argo_events_namespace]
  source            = "./modules/workflow"

  environment           = var.environment
  namespace             = var.namespace
  project               = var.project
  cluster_name          = var.cluster_name
  cluster_oidc          = var.iam_openid_provider
  argo_events_namespace = module.argo-events.argo_events_namespace
}
