#Global helm chart repo
data "helm_repository" "incubator" {
  name = "incubator"
  url  = "https://kubernetes-charts-incubator.storage.googleapis.com"
}

//TODO: при удалении выгрызать crd
resource "helm_release" "monitoring" {
  depends_on = [
    var.module_depends_on
  ]
  name       = "prometheus-operator"
  repository = "stable"
  chart      = "prometheus-operator"
  version    = "8.2.4"
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
      name  = "grafana.ingress.tls[${set.key}].hosts[${set.key}]"
      value = "grafana.${set.value}"
    }
  }

  dynamic "set" {
    for_each = var.domains
    content {
      name  = "prometheus.ingress.hosts[${set.key}]"
      value = "prometheus.${set.value}"
    }
  }
  dynamic "set" {
    for_each = var.domains
    content {
      name  = "prometheus.ingress.tls[${set.key}].hosts[0]"
      value = "prometheus.${set.value}"
    }
  }

  //TODO: Need make do disabled
  set {
      name  = "prometheus.ingress.annotations[5]"
      value = "nginx.ingress.kubernetes.io/auth-signin: https://oauth2.${var.domains[0]}/oauth2/start?rd=https://$host$request_uri$is_args$args"
    }

  set {
      name  = "prometheus.ingress.annotations[6]"
      value = "nginx.ingress.kubernetes.io/auth-url: https://oauth2.${var.domains[0]}/oauth2/auth"  
  }
}
