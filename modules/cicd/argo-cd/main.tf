data "helm_repository" "argo" {
  name = "argo"
  url  = "https://argoproj.github.io/argo-helm"
}

resource "helm_release" "argo-cd" {
  depends_on = [
    var.module_depends_on
  ]   
  
  name          = "argo-cd"
  repository    = "argo"
  chart         = "argo-cd"
  version       = "1.4.5"
  namespace     = "argo-cd"
  recreate_pods = true

  set {
    name  = "server.ingress.enabled"
    value = true
  }

  set {
    name  = "server.ingress.hosts[0]"
    value = "argo-cd.${var.domain}"
  }

  set {
    name  = "server.ingress.tls[0].hosts[0]"
    value = "argo-cd.${var.domain}"
  }

  set {
    name  = "server.ingress.tls[0].secretName"
    value = "argo-cd-com-tls"
  }

  set {
    name  = "server.ingress.tls[0].hosts[0]"
    value = "argo-cd.${var.domain}"
  }

  set {
    name  = "server.config.url"
    value = "https://argo-cd.${var.domain}"
  }
  
  values = [
    file("${path.module}/values.yml")
  ]
}
