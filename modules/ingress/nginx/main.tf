data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

resource "kubernetes_namespace" "this" {
  depends_on = [
    var.module_depends_on
  ]
  count = var.namespace == "" ? 1 : 0
  metadata {
    name = var.namespace_name
  }
}

resource "helm_release" "this" {
  count = 1 - local.argocd_enabled
  depends_on = [
    var.module_depends_on
  ]
  name       = local.name
  repository = local.repository
  chart      = local.chart
  version    = local.version
  namespace  = local.namespace
  timeout    = 1200

  dynamic "set" {
    for_each = local.conf

    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "local_file" "this" {
  count    = local.argocd_enabled
  content  = yamlencode(local.app)
  filename = "${var.argocd.path}/${local.name}.yaml"
}

locals {
  argocd_enabled = length(var.argocd) > 0 ? 1 : 0
  namespace      = coalescelist(kubernetes_namespace.this, [{ "metadata" = [{ "name" = var.namespace }] }])[0].metadata[0].name

  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.chart_version


  app = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = local.name
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = local.namespace
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = local.repository
        "targetRevision" = local.version
        "chart"          = local.chart
        "helm" = {
          "parameters" = values({
            for key, value in local.conf :
            key => {
              "name"  = key
              "value" = tostring(value)
            }
          })
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

  conf = merge(local.conf_defaults, var.conf)
  conf_defaults = merge(
    var.aws_private ? {
      "controller.service.internal.enabled"                                                        = true
      "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal" = "0.0.0.0"
    } : {},
    {
      "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"                     = "nlb"
      "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-additional-resource-tags" = join(",", values({ for t in keys(var.tags) : t => "${t}=${var.tags[t]}" }))
      "rbac.create"                                                                                                = true
      "resources.limits.cpu"                                                                                       = "100m",
      "resources.limits.memory"                                                                                    = "300Mi",
      "resources.requests.cpu"                                                                                     = "100m",
      "resources.requests.memory"                                                                                  = "300Mi",
  })
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
