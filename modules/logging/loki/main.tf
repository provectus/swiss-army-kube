#Loki chart repo
data "helm_repository" "loki" {
  name = "loki"
  url  = "https://grafana.github.io/loki/charts"
}

# For depends_on queqe
resource "null_resource" "depends_on" {
  triggers {
    depends_on = "${join("", var.depends_on)}"
  }
}

resource "helm_release" "loki-stack" {

  name       = "loki"
  repository = "loki"
  chart      = "loki-stack"
  version    = "0.20.0"
  namespace  = "logging"

  values = [
    file("${path.module}/values/loki-stack.yaml"),
  ]  
  depends_on = [
    "null_resource.depends_on"
  ]    
} 