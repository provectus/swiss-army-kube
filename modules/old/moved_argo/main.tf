resource "kubernetes_namespace" "this" {
  depends_on = [var.module_depends_on]
  metadata {
    name = var.namespace_name
  }
}

module "argo-cd" {
  source            = "./modules/cd"
  module_depends_on = var.module_depends_on
  domains           = var.domains
  namespace         = kubernetes_namespace.this.metadata[0].name
}

module "argo-events" {
  source            = "./modules/events"
  module_depends_on = var.module_depends_on
  cluster_name      = var.cluster_name
  namespace         = kubernetes_namespace.this.metadata[0].name
}

module "argo-workflow" {
  source                = "./modules/workflow"
  module_depends_on     = var.module_depends_on
  environment           = var.environment
  namespace             = kubernetes_namespace.this.metadata[0].name
  project               = var.project
  cluster_name          = var.cluster_name
  argo_events_namespace = module.argo-events.argo_events_namespace
  cluster_oidc_url      = replace(var.cluster_oidc_url, "https://", "")
}
