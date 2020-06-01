# Create namespace argo-events
resource "kubernetes_namespace" "argo-events" {
  depends_on = [
    var.module_depends_on
  ]
  metadata {
    name = "argo-events"
  }
}

resource "helm_release" "argo-events" {
  depends_on = [
    var.module_depends_on
  ]

  name          = "argo-events"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-events"
//  version       = "0.6.0"
  namespace     = "argo-events"
  recreate_pods = true

  values = [
    file("${path.module}/values.yml")
  ]
}
