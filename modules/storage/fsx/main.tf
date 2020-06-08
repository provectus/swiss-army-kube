locals {
  name           = var.cluster.cluster_id
  vpc_id         = var.vpc.id
  security_group = var.cluster.worker_security_group_id
  subnet         = var.vpc.private_subnets[0]
}

data "aws_caller_identity" "this" {}

data "aws_eks_cluster" "this" {
  name = local.name
}

resource "helm_release" "aws-fsx-csi-driver" {
  name      = "aws-fsx-csi-driver"
  chart     = "${path.module}/../../../charts/aws-fsx-csi-driver"
  namespace = "kube-system"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.this.arn
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringLike"
      variable = "${replace(data.aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:fsx-csi-controller-sa"]
    }

    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:oidc-provider/${replace(data.aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")}"]
      type        = "Federated"
    }
  }
}


resource "aws_iam_role" "this" {
  assume_role_policy = data.aws_iam_policy_document.this.json
  name               = "${var.cluster_name}-fsx-csi-driver"
}

resource "aws_iam_role_policy" "this" {
  role = aws_iam_role.this.id
  name = "aws-efs-csi-driver"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "iam:CreateServiceLinkedRole",
            "iam:AttachRolePolicy",
            "iam:PutRolePolicy"
          ],
          "Resource" : "arn:aws:iam::*:role/aws-service-role/s3.data-source.lustre.fsx.amazonaws.com/*"
        },
        {
          "Action" : "iam:CreateServiceLinkedRole",
          "Effect" : "Allow",
          "Resource" : "*",
          "Condition" : {
            "StringLike" : {
              "iam:AWSServiceName" : [
                "fsx.amazonaws.com"
              ]
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:ListBucket",
            "fsx:CreateFileSystem",
            "fsx:DeleteFileSystem",
            "fsx:DescribeFileSystems"
          ],
          "Resource" : ["*"]
        }
      ]
    }
  )
}

resource "aws_security_group_rule" "fsx-0" {
  type                     = "ingress"
  from_port                = 988
  to_port                  = 988
  protocol                 = "tcp"
  source_security_group_id = local.security_group
  description              = "Allows Lustre traffic between Lustre clients"
  security_group_id        = aws_security_group.fsx.id
}

resource "aws_security_group_rule" "fsx-1" {
  type                     = "ingress"
  from_port                = 1021
  to_port                  = 1023
  protocol                 = "tcp"
  source_security_group_id = local.security_group
  description              = "Allows Lustre traffic between Lustre clients"
  security_group_id        = aws_security_group.fsx.id
}

resource "aws_security_group" "fsx" {
  name   = "AWS FSx SG [${local.name}]"
  vpc_id = local.vpc_id
}
