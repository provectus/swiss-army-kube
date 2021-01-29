# Create namespace ingress-system
resource kubernetes_namespace this {
  depends_on = [
    var.module_depends_on
  ]
  metadata {
    name = "ingress-system"
  }
}

resource local_file this {
  depends_on = [
    var.module_depends_on
  ]
  content  = yamlencode(local.application)
  filename = "${path.root}/${var.argocd.path}/${local.name}.yaml"
}

locals {
  repository = "https://charts.helm.sh/stable"
  name       = "nginx-ingress"
  chart      = "nginx-ingress"
  values = [
    {
      "name"  = "controller.service.annotations.service.beta.kubernetes.io"
      "value" = var.aws_private == "true" ? "aws-load-balancer-internal=true" : "aws-load-balancer-internal=false"
    }
  ]
  application = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = local.name
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = kubernetes_namespace.this.metadata[0].name
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = local.repository
        "targetRevision" = "1.39.0"
        "chart"          = local.chart
        "helm" = {
          "parameters" = local.values
        }
      }
      "syncPolicy" = {
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
      }
    }
  }
}

# Deploy oauth2-proxy if github-auth set true
# resource "kubernetes_secret" "oauth2-proxy-secret" {
#   count = var.github-auth == "true" ? 1 : 0
#   depends_on = [
#     var.module_depends_on,
#     helm_release.nginx-ingress
#   ]

#   metadata {
#     name      = "oauth2-proxy-secret"
#     namespace = "ingress-system"
#   }

#   data = {
#     client-id : var.github-client-id
#     client-secret : var.github-client-secret
#     cookie-secret : var.cookie-secret
#   }
# }

# # Deploy oauth2-proxy if google-auth set true
# resource "kubernetes_secret" "oauth2-proxy-secret-google" {
#   count = var.google-auth == "true" ? 1 : 0
#   depends_on = [
#     var.module_depends_on,
#     helm_release.nginx-ingress
#   ]

#   metadata {
#     name      = "oauth2-proxy-secret-google"
#     namespace = "ingress-system"
#   }

#   data = {
#     client-id : var.google-client-id
#     client-secret : var.google-client-secret
#     cookie-secret : var.google-cookie-secret
#   }
# }


# resource "helm_release" "oauth2-proxy" {
#   count = var.github-auth == "true" ? 1 : 0
#   depends_on = [
#     var.module_depends_on,
#     kubernetes_secret.oauth2-proxy-secret,
#     helm_release.nginx-ingress
#   ]

#   name          = "oauth2-proxy"
#   repository    = "https://charts.helm.sh/stable"
#   chart         = "oauth2-proxy"
#   version       = "3.1.0"
#   namespace     = "ingress-system"
#   recreate_pods = true

#   values = [
#     file("${path.module}/values/oauth2-proxy.yaml"),
#   ]

#   set {
#     name  = "config.existingSecret"
#     value = kubernetes_secret.oauth2-proxy-secret[0].metadata[0].name
#   }

#   set {
#     name  = "extraArgs.cookie-domain"
#     value = join(", ", formatlist(".%s", var.domains))
#   }

#   set {
#     name  = "extraArgs.whitelist-domain"
#     value = join(", ", formatlist(".%s", var.domains))
#   }

#   set {
#     name  = "extraArgs.github-org"
#     value = var.github-org
#   }
#   dynamic "set" {
#     for_each = var.domains
#     content {
#       name  = "ingress.hosts[${set.key}]"
#       value = "oauth2.${set.value}"
#     }
#   }

#   dynamic "set" {
#     for_each = var.domains
#     content {
#       name  = "ingress.tls[${set.key}].secretName"
#       value = "oauth2-${set.key}-tls"
#     }
#   }

#   dynamic "set" {
#     for_each = var.domains
#     content {
#       name  = "ingress.tls[${set.key}].hosts[0]"
#       value = "oauth2.${set.value}"
#     }
#   }
# }

# resource "helm_release" "oauth2-proxy-google" {
#   count = var.google-auth == "true" ? 1 : 0
#   depends_on = [
#     var.module_depends_on,
#     kubernetes_secret.oauth2-proxy-secret-google,
#     helm_release.nginx-ingress
#   ]

#   name          = "oauth2-proxy-google"
#   repository    = "https://charts.helm.sh/stable"
#   chart         = "oauth2-proxy"
#   version       = "3.1.0"
#   namespace     = "ingress-system"
#   recreate_pods = true

#   values = [
#     file("${path.module}/values/oauth2-proxy-google.yaml")
#   ]

#   set {
#     name  = "config.existingSecret"
#     value = kubernetes_secret.oauth2-proxy-secret-google[0].metadata[0].name
#   }

#   set {
#     name  = "extraArgs.cookie-domain"
#     value = join(", ", formatlist(".%s", var.domains))
#   }

#   set {
#     name  = "extraArgs.whitelist-domain"
#     value = join(", ", formatlist(".%s", var.domains))
#   }

#   dynamic "set" {
#     for_each = var.domains
#     content {
#       name  = "ingress.hosts[${set.key}]"
#       value = "oauth2-google.${set.value}"
#     }
#   }

#   dynamic "set" {
#     for_each = var.domains
#     content {
#       name  = "ingress.tls[${set.key}].secretName"
#       value = "oauth2-google-${set.key}-tls"
#     }
#   }

#   dynamic "set" {
#     for_each = var.domains
#     content {
#       name  = "ingress.tls[${set.key}].hosts[0]"
#       value = "oauth2-google.${set.value}"
#     }
#   }
# }
