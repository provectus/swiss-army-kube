resource "helm_release" "hpa_operator" {
  depends_on = [
    var.module_depends_on
  ]
  count      = var.hpa_enabled ? 1 - local.argocd_enabled : 0
  name       = local.hpa_name
  repository = local.hpa_chart_repository
  chart      = local.hpa_chart
  version    = var.hpa_chart_version
  namespace  = local.namespace
  timeout    = 1200
  dynamic "set" {
    for_each = merge(local.hpa_conf_defaults, var.hpa_conf)

    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "local_file" "hpa" {
  count    = var.hpa_enabled ? local.argocd_enabled : 0
  content  = yamlencode(local.hpa_app)
  filename = "${var.argocd.path}/${local.hpa_name}.yaml"
}

locals {
  hpa_chart_repository = "https://kubernetes-charts.banzaicloud.com"
  hpa_name             = "hpa-operator"
  hpa_chart            = "hpa-operator"
  hpa_app = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = local.hpa_name
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = local.namespace
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = local.hpa_chart_repository
        "targetRevision" = var.hpa_chart_version
        "chart"          = local.hpa_chart
        "helm" = {
          "parameters" = values({
            for key, value in local.hpa_conf :
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
  hpa_conf = merge(local.hpa_conf_defaults, var.hpa_conf)
  hpa_conf_defaults = {
    "rbac.create"               = true,
    "rbac.pspEnabled"           = true,
    "resources.limits.cpu"      = "100m",
    "resources.limits.memory"   = "30Mi",
    "resources.requests.cpu"    = "100m",
    "resources.requests.memory" = "30Mi",
  }
}
