data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

# Create namespace ingress-system
resource "kubernetes_namespace" "ingress-system" {
  depends_on = [
    var.module_depends_on
  ]
  metadata {  
    name = "ingress-system"
  }
}

resource "helm_release" "nginx-ingress" {
  depends_on = [
    var.module_depends_on
  ]
  name       = "nginx"
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "nginx-ingress"
  namespace  = "ingress-system"

  values = [
    file("${path.module}/values/nginx-ingress.yaml"),
  ]

  set {
    name = "controller.service.annotations.service.beta.kubernetes.io"
    value = var.aws_private =="true" ?  "aws-load-balancer-internal=true" : "aws-load-balancer-internal=false"
  }
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
  repository    = data.helm_repository.stable.metadata[0].name
  chart         = "oauth2-proxy"
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
