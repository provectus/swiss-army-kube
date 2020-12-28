data "aws_region" "current" {}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

resource "kubernetes_namespace" "this" {
  count = var.namespace == "kube-system" ? 1 : 0
  metadata {
    name = var.namespace_name
  }
}

locals {
  argocd_enabled = length(var.argocd) > 0 ? 1 : 0
  namespace      = coalescelist(kubernetes_namespace.this, [{ "metadata" = [{ "name" = var.namespace }] }])[0].metadata[0].name
}
