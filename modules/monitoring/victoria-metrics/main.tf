data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_region" "current" {}

resource "kubernetes_namespace" "this" {
  depends_on = [
    var.module_depends_on
  ]
  count = var.namespace == "" ? 1 - local.argocd_enabled : 0
  metadata {
    name = var.namespace_name
  }
}

resource "local_file" "namespace" {
  count = local.argocd_enabled
  depends_on = [
    var.module_depends_on
  ]
  content = yamlencode({
    "apiVersion" = "v1"
    "kind"       = "Namespace"
    "metadata" = {
      "name" = local.namespace
    }
  })
  filename = "${path.root}/${var.argocd.path}/ns-${local.namespace}.yaml"
}

locals {
  argocd_enabled = length(var.argocd) > 0 ? 1 : 0
  namespace      = coalescelist(var.namespace == "" && local.argocd_enabled > 0 ? [{ "metadata" = [{ "name" = var.namespace_name }] }] : kubernetes_namespace.this, [{ "metadata" = [{ "name" = var.namespace }] }])[0].metadata[0].name
}

resource "helm_release" "this" {
  count = 1 - local.argocd_enabled

  depends_on = [
    var.module_depends_on
  ]

  name          = var.release_name
  repository    = var.chart_repository
  chart         = var.chart_name
  version       = var.chart_version
  namespace     = local.namespace
  recreate_pods = true
  timeout       = 1200

  dynamic "set" {
    for_each = merge(local.conf)

    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "local_file" "this" {
  count = local.argocd_enabled
  depends_on = [
    var.module_depends_on
  ]
  content  = yamlencode(local.application)
  filename = "${path.root}/${var.argocd.path}/${var.chart_name}.yaml"
}


locals {
  conf = merge(local.conf_defaults, var.conf)
  conf_defaults = {
    "namespace"                          = local.namespace
    "rbac.create"                        = true,
    "resources.limits.cpu"               = "1000m",
    "resources.limits.memory"            = "2048Mi",
    "resources.requests.cpu"             = "512m",
    "resources.requests.memory"          = "512Mi",
    "vmstorage.persistentVolume.enabled" = true,
    "vmstorage.persistentVolume.size"    = "8Gi",
    "vmselect.statefulSet.enabled"       = false,
    "vmselect.persistentVolume.enabled"  = false
  }
  application = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = var.release_name
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = local.namespace
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = var.chart_repository
        "targetRevision" = var.chart_version
        "chart"          = var.chart_name
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
}
