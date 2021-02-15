resource "helm_release" "cluster_autoscaler" {
  depends_on = [
    var.module_depends_on
  ]
  count      = var.cluster_autoscaler_enabled ? 1 - local.argocd_enabled : 0
  name       = local.cluster_autoscaler_name
  repository = local.cluster_autoscaler_chart_repository
  chart      = local.cluster_autoscaler_chart
  version    = var.cluster_autoscaler_chart_version
  namespace  = local.namespace
  timeout    = 1200
  dynamic "set" {
    for_each = local.cluster_autoscaler_conf

    content {
      name  = set.key
      value = set.value
    }
  }
}

module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v3.6.0"
  create_role                   = var.cluster_autoscaler_enabled
  role_name                     = "${var.cluster_name}_cluster-autoscaler"
  provider_url                  = replace(data.aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.cluster_autoscaler[0].arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.namespace}:aws-cluster-autoscaler"]

  tags = var.tags
}

resource "aws_iam_policy" "cluster_autoscaler" {
  depends_on = [
    var.module_depends_on
  ]
  count       = var.cluster_autoscaler_enabled ? 1 : 0
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

resource "local_file" "cluster_autoscaler" {
  count    = var.cluster_autoscaler_enabled ? local.argocd_enabled : 0
  content  = yamlencode(local.cluster_autoscaler_app)
  filename = "${var.argocd.path}/${local.cluster_autoscaler_name}.yaml"
}

locals {
  cluster_autoscaler_chart_repository = "https://charts.helm.sh/stable"
  cluster_autoscaler_name             = "aws-cluster-autoscaler"
  cluster_autoscaler_chart            = "cluster-autoscaler"
  cluster_autoscaler_app = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = local.cluster_autoscaler_name
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = local.namespace
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = local.cluster_autoscaler_chart_repository
        "targetRevision" = var.cluster_autoscaler_chart_version
        "chart"          = local.cluster_autoscaler_chart
        "helm" = {
          "parameters" = values({
            for key, value in local.cluster_autoscaler_conf :
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
  cluster_autoscaler_conf = merge(local.cluster_autoscaler_conf_defaults, var.cluster_autoscaler_conf)
  cluster_autoscaler_conf_defaults = {
    "cloudProvider"                                                 = "aws"
    "image.repository"                                              = "us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler"
    "image.tag"                                                     = "v1.16.6" # Make sure it matches the version of the cluster
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
