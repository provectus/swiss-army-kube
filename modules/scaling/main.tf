data "aws_region" "current" {}

data "aws_caller_identity" "this" {}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

resource "kubernetes_namespace" "this" {
  depends_on = [
    var.module_depends_on
  ]
  count = var.namespace == "kube-system" ? 0 : 1
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "cluster_autoscaler" {
  depends_on = [
    var.module_depends_on
  ]
  name       = "aws-cluster-autoscaler"
  repository = "https://kubernetes-charts.storage.googleapis.com/"
  chart      = "cluster-autoscaler"
  version    = "7.2.2"
  namespace  = var.namespace
  timeout    = 1200
  dynamic set {
    for_each = merge(local.autoscaler_conf_defaults, var.autoscaler_conf)

    content {
      name  = set.key
      value = set.value
    }
  }
}

module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.6.0"
  create_role                   = true
  role_name                     = "${var.cluster_name}_cluster-autoscaler"
  provider_url                  = replace(data.aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.cluster_autoscaler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-cluster-autoscaler"]
}

resource "aws_iam_policy" "cluster_autoscaler" {
  depends_on = [
    var.module_depends_on
  ]
  name_prefix = "cluster-autoscaler"
  description = "EKS cluster-autoscaler policy for cluster ${data.aws_eks_cluster.this.id}"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid    = "clusterAutoscalerAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "clusterAutoscalerOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${data.aws_eks_cluster.this.id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}

locals {
  autoscaler_conf_defaults = {
    "cloudProvider"                                                 = "aws"
    "image.repository"                                              = "us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler"
    "image.tag"                                                     = "v1.16.6"
    "autoDiscovery.clusterName"                                     = var.cluster_name,
    "autoDiscovery.enabled"                                         = true
    "awsRegion"                                                     = data.aws_region.current.name,
    "extraArgs.balance-similar-node-groups"                         = true,
    "extraArgs.scale-down-enabled"                                  = true,
    "rbac.create"                                                   = true,
    "rbac.serviceAccountAnnotations.eks\\.amazonaws\\.com/role-arn" = module.iam_assumable_role_admin.this_iam_role_arn
    "rbac.pspEnabled"                                               = true,
    "resources.limits.cpu"                                          = "100m",
    "resources.limits.memory"                                       = "300Mi",
    "resources.requests.cpu"                                        = "100m",
    "resources.requests.memory"                                     = "300Mi",
  }
}
