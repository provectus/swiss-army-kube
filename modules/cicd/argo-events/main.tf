data "helm_repository" "argo" {
  name = "argo"
  url  = "https://argoproj.github.io/argo-helm"
}

resource "helm_release" "argo-events" {
  depends_on = [
    var.module_depends_on
  ]   
  
  name          = "argo-events"
  repository    = "argo"
  chart         = "argo-events"
  version       = "0.6.0"
  namespace     = "argo-events"
  recreate_pods = true

  values = [
    file("${path.module}/values.yml")
  ]
}
