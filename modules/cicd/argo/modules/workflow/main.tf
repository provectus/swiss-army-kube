data "aws_region" "current" {}

data "aws_eks_cluster" "this" {
  depends_on = [
    var.module_depends_on
  ]
  name = var.cluster_name
}

resource "aws_s3_bucket" "artifacts" {
  depends_on = [
    var.module_depends_on
  ]
  bucket = "${var.cluster_name}-argo-artifacts"
  acl    = "private"
  region = data.aws_region.current.name

  tags = {
    Name        = "${var.cluster_name}-argo-artifacts"
    Environment = var.environment
    Project     = var.project
    Team        = "DevOps"
    Description = "for argo artifacts in kubernetes"
  }
}

resource "aws_iam_role_policy" "s3" {
  name = "s3-access"
  role = module.sa_assumable_role.this_iam_role_name
  policy = jsonencode(
    { "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AllowS3ActionsInBucket",
          "Effect" : "Allow",
          "Action" : [
            "s3:PutObject",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:GetBucketLocation"
          ],
          "Resource" : ["${aws_s3_bucket.artifacts.arn}/*",
          aws_s3_bucket.artifacts.arn]
        }
      ]
    }
  )
}

module "sa_assumable_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.6.0"
  create_role                   = true
  role_name                     = "${var.cluster_name}_argo-workflow"
  provider_url                  = replace(data.aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.namespace}:argo-*"]
}

resource "helm_release" "argo-workflow" {
  depends_on = [
    var.module_depends_on
  ]

  name          = "argo-workflow"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo"
  version       = "0.9.4"
  namespace     = var.namespace
  recreate_pods = true

  dynamic set {
    for_each = merge(local.workflow_conf_defaults, var.workflow_conf)

    content {
      name  = set.key
      value = set.value
    }
  }
}

locals {
  workflow_conf_defaults = {
    "useDefaultArtifactRepo"                                              = true,
    "artifactRepository.s3.endpoint"                                      = "s3.amazonaws.com",
    "artifactRepository.archiveLogs"                                      = true,
    "artifactRepository.s3.bucket"                                        = aws_s3_bucket.artifacts.bucket,
    "artifactRepository.s3.useSDKCreds"                                   = true,
    "controller.resources.limits.cpu"                                     = "100m",
    "controller.resources.limits.memory"                                  = "300Mi",
    "controller.resources.requests.cpu"                                   = "100m",
    "controller.resources.requests.memory"                                = "300Mi",
    "controller.serviceAccountAnnotations.eks\\.amazonaws\\.com/role-arn" = module.sa_assumable_role.this_iam_role_arn,
    "controller.workflowNamespaces[0]"                                    = var.argo_events_namespace,
    "installCRD"                                                          = false,
    "rbac.create"                                                         = true,
    "rbac.pspEnabled"                                                     = true,
    "server.baseHref"                                                     = "/argo/"
    "server.resources.limits.cpu"                                         = "100m",
    "server.resources.limits.memory"                                      = "300Mi",
    "server.resources.requests.cpu"                                       = "100m",
    "server.resources.requests.memory"                                    = "300Mi",
    "server.serviceAccountAnnotations.eks\\.amazonaws\\.com/role-arn"     = module.sa_assumable_role.this_iam_role_arn
  }
}
