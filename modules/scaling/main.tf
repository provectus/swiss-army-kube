data "aws_region" "current" {}

resource "kubernetes_namespace" "this" {
  count = var.namespace_name == "kube-system" ? 0 : 1
  metadata {
    name = var.namespace_name
  }
}

resource "kubernetes_limit_range" "this" {
  metadata {
    name      = "default-limits"
    namespace = var.namespace_name
  }
  spec {
    limit {
      type = "Container"
      max = {
        cpu    = "500m"
        memory = "1G"
      }
      default = {
        cpu    = "200m"
        memory = "512M"
      }
      default_request = {
        cpu    = "50m"
        memory = "128M"
      }
    }
  }
}

locals {
  cluster_autoscaler_defaults = {
    "autoDiscovery.clusterName"             = var.cluster_name,
    "awsRegion"                             = data.aws_region.current.name,
    "extraArgs.balance-similar-node-groups" = true,
    "rbac.create"                           = true,
    "rbac.pspEnabled"                       = true,
  }
}

resource "helm_release" "cluster_autoscaler" {
  count      = var.cluster_autoscaler.enabled ? 1 : 0
  name       = "aws-cluster-autoscaler"
  repository = "stable"
  chart      = "cluster-autoscaler"
  version    = "6.0.0"
  namespace  = var.namespace_name

  dynamic set {
    for_each = merge(local.cluster_autoscaler_defaults, var.cluster_autoscaler.parameters)

    content {
      name  = set.key
      value = set.value
    }
  }
}
