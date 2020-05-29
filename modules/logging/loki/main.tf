#Loki chart repo
data "helm_repository" "loki" {
  name = "loki"
  url  = "https://grafana.github.io/loki/charts"
}

resource "helm_release" "loki-stack" {
  depends_on = [
    var.module_depends_on
  ]

  name       = "loki"
  repository = data.helm_repository.loki.metadata[0].name
  chart      = "loki-stack"
  version    = "0.27.0"
  namespace  = "logging"

  values = [
    file("${path.module}/values/loki-stack.yaml"),
  ]
} 