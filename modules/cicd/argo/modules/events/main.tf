resource "helm_release" "argo-events" {
  depends_on = [
    var.module_depends_on
  ]

  name          = "argo-events"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-events"
  version       = "0.14.0"
  namespace     = var.namespace
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
  events_conf_defaults = {
    "installCRD" = false
  }
}
