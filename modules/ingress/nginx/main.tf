#Global helm chart repo
data "helm_repository" "incubator" {
  name = "incubator"
  url  = "https://kubernetes-charts-incubator.storage.googleapis.com"
}

resource "helm_release" "nginx-ingress" {
  depends_on = [
    var.module_depends_on
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


# Deploy oauth2-proxy if github-auth set true
resource "kubernetes_secret" "oauth2-proxy" {
  count = var.github-auth == "true" ? 1 : 0
  depends_on = [
    var.module_depends_on,
    helm_release.nginx-ingress
  ]

  metadata {
    name      = "oauth-proxy-secret"
    namespace = "ingress-system"
  }

  data = {
    github-client-id : var.github-client-id
    github-client-secret : var.github-client-secret
    cookie-secret : var.cookie-secret
  }
}


resource "helm_release" "oauth2-proxy" {
  count = var.github-auth == "true" ? 1 : 0
  depends_on = [
    var.module_depends_on,
    kubernetes_secret.oauth2-proxy,
    helm_release.nginx-ingress
  ]

  name          = "oauth2-proxy"
  repository    = "stable"
  chart         = "oauth2-proxy"
  version       = "2.1.1"
  namespace     = "ingress-system"
  recreate_pods = true

  values = [
    "${file("${path.module}/values/oauth2-proxy.yaml")}",
  ]

  set {
    name  = "extraArgs.cookie-domain"
    value = join(", ", var.domains)
  }

  set {
    name  = "extraArgs.whitelist-domain"
    value = join(", ", var.domains)
  }

  set {
    name  = "extraArgs.github-org"
    value = var.github-org
  }
  dynamic "set" {
    for_each = var.domains
    content {
      name  = "ingress.hosts[${set.key}]"
      value = "oauth2.${set.value}"
    }
  }
  dynamic "set" {
    for_each = var.domains
    content {
      name  = "ingress.tls[${set.key}].secretName"
      value = "oauth2-${set.key}-tls"
    }
  }
  dynamic "set" {
    for_each = var.domains
    content {
      name  = "ingress.tls[${set.key}].hosts[0]"
      value = "oauth2.${set.value}"
    }
  }
}
