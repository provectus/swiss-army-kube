

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_secretsmanager_secret" "rds_username" {
  name = "${var.cluster_name}/mlflow/rds_username"
}
resource "aws_secretsmanager_secret_version" "rds_username" {
  secret_id     = aws_secretsmanager_secret.rds_username.id
  secret_string = var.rds_username
}
resource "aws_secretsmanager_secret" "rds_password" {
  name = "${var.cluster_name}/mlflow/rds_password"
}
resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = var.rds_password
}


module "iam_assumable_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v3.6.0"
  create_role                   = true
  role_name                     = "${data.aws_eks_cluster.this.id}_${local.name}"
  provider_url                  = replace(data.aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.this.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.namespace}:${local.name}"]

  tags = var.tags
}

resource "aws_iam_role_policy" "this" {
  name  = "mlflow-${local.cluster_name}-access"

  policy = <<-EOF
{
  "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "SecretsAccess",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:ListSecretVersionIds",
                "secretsmanager:GetSecretValue",
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:DescribeSecret"
            ],
            "Resource": "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.cluster_name}/${var.allowed_secrets_prefix}*"
        }
    ]
}
  EOF
}


resource local_file mlflow_def {
  content = local.mlflow_def
  filename = "${path.root}/${var.argocd.path}/mlflow-defs/mlflow_def.yaml"
}


resource local_file namespace {
  content = local.namespace
  filename = "${path.root}/${var.argocd.path}/mlflow-namespace.yaml"
}


resource local_file mlflow {
  content = yamlencode({
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "mlflow"
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = "mlflow"
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = var.argocd.repository
        "targetRevision" = var.argocd.branch
        "path"           = "${var.argocd.full_path}/mlflow-defs"
      }
      "syncPolicy" = {
        "syncOptions" = [
          "CreateNamespace=false"
        ]
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
      }
    }
  })
  filename = "${path.root}/${var.argocd.path}/mlflow.yaml"
}
