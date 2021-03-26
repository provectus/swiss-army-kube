data "aws_region" "current" {}

data "aws_caller_identity" "this" {}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

module "iam_assumable_role_admin" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  # version                       = "~> v2.6.0"
  create_role                   = true
  role_name                     = "${var.cluster_name}_cluster-autoscaler"
  provider_url                  = replace(data.aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.cluster_autoscaler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.namespace}:aws-cluster-autoscaler-chart"]
  tags                          = var.tags
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

resource "kubernetes_namespace" "this" {
  count = var.namespace == "kube-system" ? 0 : 1
  depends_on = [
    var.module_depends_on
  ]
  metadata {
    name = var.namespace
  }
}

resource "local_file" "this" {
  content  = yamlencode(local.application)
  filename = "${path.root}/${var.argocd.path}/${local.name}.yaml"
}

locals {
  repository = "https://kubernetes.github.io/autoscaler"
  name       = "aws-cluster-autoscaler-chart"
  chart      = "cluster-autoscaler-chart"
  values = [
    {
      "name"  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      "value" = module.iam_assumable_role_admin.this_iam_role_arn
    },
    {
      "name"  = "cloudProvider"
      "value" = "aws"
    },
    {
      "name"  = "image.repository"
      "value" = "us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler"
    },
    {
      "name"  = "image.tag"
      "value" = var.image_tag
    },
    {
      "name"  = "autoDiscovery.clusterName"
      "value" = var.cluster_name,
    },
    {
      "name"  = "autoDiscovery.enabled"
      "value" = "true"
    },
    {
      "name"  = "awsRegion"
      "value" = data.aws_region.current.name,
    },
    {
      "name"  = "extraArgs.balance-similar-node-groups"
      "value" = "true",
    },
    {
      "name"  = "extraArgs.scale-down-enabled"
      "value" = "true",
    },
    {
      "name"  = "rbac.create"
      "value" = "true",
    },
    {
      "name"  = "rbac.pspEnabled"
      "value" = "true",
    },
    {
      "name"  = "resources.limits.cpu"
      "value" = "100m",
    },
    {
      "name"  = "resources.limits.memory"
      "value" = "300Mi",
    },
    {
      "name"  = "resources.requests.cpu"
      "value" = "100m",
    },
    {
      "name"  = "resources.requests.memory"
      "value" = "300Mi"
    }
  ]
  application = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = local.name
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = var.namespace
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = local.repository
        "targetRevision" = var.chart_version
        "chart"          = local.chart
        "helm" = {
          "parameters" = local.values
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
