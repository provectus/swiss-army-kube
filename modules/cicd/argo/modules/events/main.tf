data "helm_repository" "argo" {
  name = "argo"
  url  = "https://argoproj.github.io/argo-helm"
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argo-events" {
  depends_on = [
    var.module_depends_on
  ]

  name          = "argo-events"
  repository    = "argo"
  chart         = "argo-events"
  version       = "0.14.0"
  namespace     = kubernetes_namespace.this.metadata[0].name
  recreate_pods = true

  dynamic set {
    for_each = merge(local.events_conf_defaults, var.events_conf)

    content {
      name  = set.key
      value = set.value
    }
  }
}

locals {
  events_conf_defaults = {}
}
