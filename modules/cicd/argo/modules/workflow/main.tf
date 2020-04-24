data "aws_region" "current" {}

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


#  policy = jsonencode(
#    { "Version" : "2012-10-17",
#      "Statement" : [
#        {
#          "Sid" : "AllowS3ActionsInBucket",
#          "Effect" : "Allow",
#          "Action" : [
#            "s3:PutObject",
#            "s3:GetObject",
#            "s3:GetBucketLocation"
#          ],
#          "Resource" : ["arn:aws:s3:::${aws_s3_bucket.artifacts.bucket}/*"]
#        }
#      ]
#    }
# )

data "aws_iam_policy_document" "aw" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.namespace}:argo-server"]
    }

    principals {
      identifiers = [var.cluster_oidc.arn]
      type        = "Federated"
    }
  }
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}


resource "aws_iam_role" "aw" {
  depends_on = [
    var.module_depends_on
  ]
  assume_role_policy = data.aws_iam_policy_document.aw.json
  name               = "${var.cluster_name}-argo-workflow"

  tags = {
    Environment = var.environment
    Project     = var.project
  }

}


data "helm_repository" "argo" {
  name = "argo"
  url  = "https://argoproj.github.io/argo-helm"
}

resource "helm_release" "argo-workflow" {
  depends_on = [
    var.module_depends_on
  ]

  name          = "argo-workflow"
  repository    = "argo"
  chart         = "argo"
  version       = "0.7.3"
  namespace     = kubernetes_namespace.this.metadata[0].name
  recreate_pods = true

  dynamic set {
    for_each = merge(local.workflow_conf_defaults, var.workflow_conf)

    content {
      name  = set.key
      value = set.value
    }
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig kubeconfig_${var.cluster_name} annotate serviceaccount -n ${kubernetes_namespace.this.metadata[0].name} argo-server eks.amazonaws.com/role-arn=${aws_iam_role.aw.arn}"
  }
}

locals {
  workflow_conf_defaults = {
    "artifactRepository.s3.bucket"         = aws_s3_bucket.artifacts.bucket,
    "rbac.create"                          = true,
    "rbac.pspEnabled"                      = true,
    "server.resources.limits.cpu"          = "100m",
    "server.resources.limits.memory"       = "300Mi",
    "server.resources.requests.cpu"        = "100m",
    "server.resources.requests.memory"     = "300Mi",
    "controller.workflowNamespaces[0]"     = var.argo_events_namespace,
    "controller.resources.limits.cpu"      = "100m",
    "controller.resources.limits.memory"   = "300Mi",
    "controller.resources.requests.cpu"    = "100m",
    "controller.resources.requests.memory" = "300Mi",
  }
}
