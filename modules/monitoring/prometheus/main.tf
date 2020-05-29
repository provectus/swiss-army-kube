#Global helm chart repo
data "helm_repository" "incubator" {
  name = "incubator"
  url  = "https://kubernetes-charts-incubator.storage.googleapis.com"
}

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
  repository = "stable"
  chart      = "prometheus-operator"
  version    = "8.5.14"
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
