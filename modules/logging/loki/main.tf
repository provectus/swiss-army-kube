# Create namespace logging
resource "kubernetes_namespace" "logging" {
  depends_on = [
    var.module_depends_on
  ]
  metadata {
    name = "logging"
  }
}

resource "helm_release" "loki-stack" {
  depends_on = [
    var.module_depends_on
  ]

  name       = "loki"
  repository = "https://grafana.github.io/loki/charts"
  chart      = "loki-stack"
  version    = "0.37.3"
  namespace  = "logging"

  values = [
    file("${path.module}/values/loki-stack.yaml"),
  ]
} 