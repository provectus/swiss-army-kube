#Global helm chart repo
data "helm_repository" "incubator" {
  name = "incubator"
  url  = "https://kubernetes-charts-incubator.storage.googleapis.com"
}

//TODO: при удалении выгрызать crd
resource "helm_release" "monitoring" {
    
  name       = "prometheus-operator"
  repository = "stable"
  chart      = "prometheus-operator"
  version    = "8.2.4"
  namespace  = "monitoring"

  values = [
    file("${path.module}/values/prometheus.yaml"),
  ]

  set {
    name  = "grafana.ingress.hosts[0]"
    value = "grafana.${var.cluster_name}.${var.domain}"
  }

  set {
    name  = "grafana.ingress.tls[0].hosts[0]"
    value = "grafana.${var.cluster_name}.${var.domain}"
  }
}
