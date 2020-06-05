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
      variable = "${replace(var.cluster_oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:fsx-csi-controller-sa"]
    }

    principals {
      identifiers = [var.cluster_oidc.arn]
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
