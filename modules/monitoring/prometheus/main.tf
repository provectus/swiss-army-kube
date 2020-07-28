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
    name  = "grafana.grafana\\.ini.auth\\.google.enabled"
    value = var.grafana_google_auth
  }

  set {
    name  = "grafana.grafana\\.ini.server.domain"
    value = "grafana.${var.domains[0]}"
  }

  set {
    name  = "grafana.grafana\\.ini.server.root_url"
    value = "https://grafana.${var.domains[0]}"
  }

  set {
    name  = "grafana.grafana\\.ini.auth\\.google.allowed_domains"
    value = var.grafana_allowed_domains
  }

  set {
    name  = "grafana.envFromSecret"
    value = var.grafana_google_auth == true ? "grafana-auth" : ""
  }

  set {
    name  = "grafana.adminPassword"
    value = var.grafana_password
  }
}

resource "kubernetes_secret" "grafana_auth" {
  depends_on = [
    var.module_depends_on
  ]

  count = var.grafana_google_auth == true ? 1 : 0

  metadata {
    name      = "grafana-auth"
    namespace = "monitoring"
  }

  data = {
    GF_AUTH_GOOGLE_CLIENT_ID     = var.grafana_client_id
    GF_AUTH_GOOGLE_CLIENT_SECRET = var.grafana_client_secret
  }
}