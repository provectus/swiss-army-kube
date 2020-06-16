# Create namespace monitoring
resource "kubernetes_namespace" "monitoring" {
  depends_on = [
    var.module_depends_on
  ]
  metadata {
    name = "monitoring"
  }
}

//TODO: при удалении выгрызать crd
resource "helm_release" "monitoring" {
  depends_on = [
    var.module_depends_on
  ]
  name       = "prometheus-operator"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "prometheus-operator"
  version    = "8.13.9"
  namespace  = "monitoring"

  values = [
    file("${path.module}/values/prometheus.yaml"),
  ]

  dynamic "set" {
    for_each = var.domains
    content {
      name  = "grafana.ingress.hosts[${set.key}]"
      value = "grafana.${set.value}"
    }
  }

  dynamic "set" {
    for_each = var.domains
    content {
      name  = "grafana.ingress.tls[${set.key}].hosts[0]"
      value = "grafana.${set.value}"
    }
  }

  set {
    name  = "grafana.adminPassword"
    value = var.grafana_password
  }
}
