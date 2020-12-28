resource "kubernetes_secret" "this" {
  depends_on = [
    var.module_depends_on
  ]
  metadata {
    name      = "${local.name}-secret"
    namespace = local.namespace
  }
  data = {
    "client-id"     = var.client_id
    "client-secret" = var.client_secret
    "cookie-secret" = var.cookie_secret
  }
}

resource "helm_release" "this" {
  count = 1 - local.argocd_enabled
  depends_on = [
    var.module_depends_on
  ]
  name          = local.name
  repository    = local.repository
  chart         = local.chart
  version       = local.version
  namespace     = local.namespace
  recreate_pods = true

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

  name       = "oauth2-proxy"
  repository = "https://charts.helm.sh/stable"
  chart      = "oauth2-proxy"
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
    {
      "rbac.create"                = true
      "resources.limits.cpu"       = "100m",
      "resources.limits.memory"    = "300Mi",
      "resources.requests.cpu"     = "100m",
      "resources.requests.memory"  = "300Mi",
      "config.existingSecret"      = kubernetes_secret.this[0].metadata[0].name,
      "extraArgs.cookie-domain"    = join(", ", formatlist(".%s", var.domains)),
      "extraArgs.whitelist-domain" = join(", ", formatlist(".%s", var.domains))
    },
    {
      for i, domain in tolist(var.domains) :
      "ingress.hosts[${set.key}]" => "oauth2.${set.value}"
    }
  )
}
