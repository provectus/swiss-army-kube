resource "helm_release" "hpa_operator" {
  depends_on = [
    var.module_depends_on
  ]
  count      = var.hpa_enabled ? 1 : 0
  name       = "hpa-operator"
  repository = "https://kubernetes-charts.banzaicloud.com"
  chart      = "hpa-operator"
  version    = var.hpa_chart_version
  namespace  = data.kubernetes_namespace.this[0].metadata[0].name
  timeout    = 1200
  dynamic set {
    for_each = merge(local.hpa_conf_defaults, var.hpa_conf)

    content {
      name  = set.key
      value = set.value
    }
  }
}

locals {
  hpa_conf_defaults = {}
}
