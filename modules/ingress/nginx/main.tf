#Global helm chart repo
data "helm_repository" "incubator" {
  name = "incubator"
  url  = "https://kubernetes-charts-incubator.storage.googleapis.com"
}

# For depends_on queqe
resource "null_resource" "module_depends_on" {
  triggers {
    depends_on = join("", var.module_depends_on)
  }
}

resource "helm_release" "nginx-ingress" {
  depends_on = [
    null_resource.module_depends_on
  ]   
  name       = "nginx"
  repository = "stable"
  chart      = "nginx-ingress"
  version    = "1.26.1"
  namespace  = "ingress-system"

  values = [
    file("${path.module}/values/nginx-ingress.yaml"),
  ]
}
