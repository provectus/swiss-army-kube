data aws_eks_cluster this {
  name = var.cluster_name
}

resource kubernetes_namespace this {
  depends_on = [
    var.module_depends_on
  ]
  count = var.namespace == "" ? 1 : 0
  metadata {
    name = var.namespace_name
  }
}

resource helm_release this {
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

  dynamic set {
    for_each = local.conf

    content {
      name  = set.key
      value = set.value
    }
  }
}

resource local_file this {
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
      "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type" = "nlb"
      "rbac.create"                                                                            = true
      "resources.limits.cpu"                                                                   = "100m",
      "resources.limits.memory"                                                                = "300Mi",
      "resources.requests.cpu"                                                                 = "100m",
      "resources.requests.memory"                                                              = "300Mi",
  })
}
