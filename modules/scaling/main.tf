data "aws_region" "current" {}

resource "kubernetes_namespace" "this" {
  count = var.namespace == "kube-system" ? 0 : 1
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "cluster_autoscaler" {
  name       = "aws-cluster-autoscaler"
  repository = "stable"
  chart      = "cluster-autoscaler"
  version    = "7.2.2"
  namespace  = var.namespace

  dynamic set {
    for_each = merge(local.autoscaler_conf_defaults, var.autoscaler_conf)

    content {
      name  = set.key
      value = set.value
    }
  }
}

locals {
  autoscaler_conf_defaults = {
    "image.tag"                             = "v1.15.5"
    "autoDiscovery.clusterName"             = var.cluster_name,
    "awsRegion"                             = data.aws_region.current.name,
    "extraArgs.balance-similar-node-groups" = true,
    "extraArgs.scale-down-enabled"          = true,
    "rbac.create"                           = true,
    "rbac.pspEnabled"                       = true,
    "resources.limits.cpu"                  = "100m",
    "resources.limits.memory"               = "300Mi",
    "resources.requests.cpu"                = "100m",
    "resources.requests.memory"             = "300Mi",
  }
}
