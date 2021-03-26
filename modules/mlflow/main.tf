data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_secretsmanager_secret" "rds_username" {
  name                    = "${var.cluster_name}/${var.namespace}/rds_username"
  recovery_window_in_days = 0
}
resource "aws_secretsmanager_secret_version" "rds_username" {
  secret_id     = aws_secretsmanager_secret.rds_username.id
  secret_string = var.rds_username
}
resource "aws_secretsmanager_secret" "rds_password" {
  name                    = "${var.cluster_name}/${var.namespace}/rds_password"
  recovery_window_in_days = 0
}
resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = var.rds_password
}


module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "3.0"
  count   = var.external_secrets_secret_role_arn == "" ? 1 : 0

  trusted_role_arns                 = [var.external_secrets_deployment_role_arn]
  create_role                       = true
  role_name                         = "${var.cluster_name}_${var.namespace}_external-secrets-mlflow"
  role_requires_mfa                 = false
  custom_role_policy_arns           = [aws_iam_policy.this[0].arn]
  number_of_custom_role_policy_arns = 1
  tags                              = var.tags
}

resource "aws_iam_policy" "this" {
  count  = var.external_secrets_secret_role_arn == "" ? 1 : 0
  name   = "${var.cluster_name}_${var.namespace}_external-secrets-mlflow-access"
  policy = <<-EOT
{
  "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:ListSecretVersionIds",
                "secretsmanager:GetSecretValue",
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:DescribeSecret"
            ],
            "Resource": "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.cluster_name}/${var.namespace}*"
        }
    ]
}
EOT
}

resource "local_file" "mlflow_def" {
  content  = local.mlflow_def
  filename = "${path.root}/${var.argocd.path}/mlflow-defs/${var.namespace}/mlflow-def.yaml"
}


resource "local_file" "namespace" {
  content  = local.namespace_def
  filename = "${path.root}/${var.argocd.path}/mlflow-defs/${var.namespace}/mlflow-namespace.yaml"
}


resource "local_file" "mlflow" {
  content = yamlencode({
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "${var.namespace}-mlflow"
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = var.namespace
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = var.argocd.repository
        "targetRevision" = var.argocd.branch
        "path"           = "${var.argocd.full_path}/mlflow-defs/${var.namespace}"
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
  filename = "${path.root}/${var.argocd.path}/mlflow-${var.namespace}.yaml"
}
