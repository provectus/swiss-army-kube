data "aws_region" "current" {}

data "aws_caller_identity" "this" {}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "kubernetes_namespace" "this" {
  depends_on = [
    var.module_depends_on
  ]
  count = var.hpa_enabled || var.cluster_autoscaler_enabled ? 1 : 0
  metadata {
    name = var.namespace == "kube-system" ? "kube-system" : kubernetes_namespace.this[0].metadata[0].name
  }
}

resource "kubernetes_namespace" "this" {
  depends_on = [
    var.module_depends_on
  ]
  count = var.namespace != "kube-system" && (var.hpa_enabled || var.cluster_autoscaler_enabled) ? 1 : 0
  metadata {
    name = var.namespace
  }
}
