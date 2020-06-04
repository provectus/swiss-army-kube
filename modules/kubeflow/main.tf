data "aws_region" "this" {}

data "aws_caller_identity" "this" {}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

resource "aws_db_subnet_group" "this" {
  subnet_ids = var.vpc.private_subnets
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                = 2
  identifier           = "${var.cluster_name}-${count.index}"
  cluster_identifier   = aws_rds_cluster.db.id
  instance_class       = "db.r5.large"
  db_subnet_group_name = aws_db_subnet_group.this.name
}

resource "aws_rds_cluster" "db" {
  cluster_identifier     = var.cluster_name
  availability_zones     = var.vpc.azs
  database_name          = "kubeflow"
  master_username        = "admin"
  master_password        = "testtest"
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.cluster.worker_security_group_id]
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:kubeflow:pipeline-runner"]
    }

    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:oidc-provider/${replace(data.aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")}"]
      type        = "Federated"
    }
  }
}

# TODO: delete user after updating aws-go-sdk
resource "aws_iam_user" "this" {
  name = "${var.cluster_name}-ml-pipeline"
}

resource "aws_iam_access_key" "this" {
  user = "${aws_iam_user.this.name}"
}

resource "aws_iam_role" "this" {
  assume_role_policy = data.aws_iam_policy_document.this.json
  name               = "${var.cluster_name}-pipeline-runner"
}

resource "aws_iam_role_policy" "this" {
  name = "s3-access"
  role = aws_iam_role.this.id

  policy = jsonencode(
    {
      Version : "2012-10-17",
      Statement : [
        {
          Action : [
            "s3:*",
          ],
          Effect : "Allow",
          Resource : [
            var.artifacts.arn,
            "${var.artifacts.arn}/*"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_user_policy" "this" {
  name = "s3-access"
  user = aws_iam_user.this.id
  # role = aws_iam_role.this.id

  policy = jsonencode(
    {
      Version : "2012-10-17",
      Statement : [
        {
          Action : [
            "s3:*",
          ],
          Effect : "Allow",
          Resource : [
            var.artifacts.arn,
            "${var.artifacts.arn}/*"
          ]
        }
      ]
    }
  )
}

resource "null_resource" "kfctl" {
  triggers = {
    api-service = local_file.api-service.id,
    metadata    = local_file.metadata.id,
    api-service = local_file.metadata-secrets.id,
  }

  depends_on = [
    "aws_iam_role.this",
    "aws_rds_cluster.db"
  ]
  provisioner "local-exec" {
    command = "kfctl apply -f ${path.module}/kfctl.yaml"
  }
}
