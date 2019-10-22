resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace_name
  }
}

resource "helm_release" "cluster_autoscaler" {
  count      = var.cluster_autoscaler.enabled ? 1 : 0
  name       = "aws-cluster-autoscaler"
  repository = "stable"
  chart      = "cluster-autoscaler"
  version    = "6.0.0"
  namespace  = "var.namespace_name"

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "rbac.create"
    value = true
  }
  
  set {
    name  = "rbac.pspEnabled"
    value = true
  }

  set {
    name = "awsRegion"
    value = true
  }
  
  set {
    name  = "extraArgs.balance-similar-node-groups"
    value = true
  }
}
