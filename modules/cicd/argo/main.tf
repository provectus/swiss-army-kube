resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

module "argo-cd" {
  module_depends_on = var.module_depends_on
  source            = "./modules/cd"
  domains           = var.domains
  namespace         = var.namespace
}

module "argo-events" {
  module_depends_on = var.module_depends_on
  source            = "./modules/events"
  namespace         = var.namespace
}

module "argo-workflow" {
  module_depends_on = concat([module.argo-events.argo_events_namespace],var.module_depends_on)
  source            = "./modules/workflow"

  environment           = var.environment
  namespace             = var.namespace
  project               = var.project
  cluster_name          = var.cluster_name
  argo_events_namespace = module.argo-events.argo_events_namespace
}
