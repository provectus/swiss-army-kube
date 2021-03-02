

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_secretsmanager_secret" "rds_username" {
  name = "${var.cluster_name}/${var.namespace}/rds_username"
}
resource "aws_secretsmanager_secret_version" "rds_username" {
  secret_id     = aws_secretsmanager_secret.rds_username.id
  secret_string = var.rds_username
}
resource "aws_secretsmanager_secret" "rds_password" {
  name = "${var.cluster_name}/${var.namespace}_rds_password"
}
resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = var.rds_password
}


resource "aws_iam_role" "external_secrets_mlflow" {
  count = var.external_secrets_secret_role_arn == "" ? 1 : 0
  name  = "${var.cluster_name}_${var.namespace}_external-secrets-mlflow"
  tags  = var.tags

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "${var.external_secrets_deployment_role_arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "external_secrets_access" {
  
  count = var.external_secrets_secret_role_arn == "" ? 1 : 0
  name  = "${var.cluster_name}_${var.namespace}_external-secrets-mlflow-access"
  role  = aws_iam_role.external_secrets_mlflow[count.index].id
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
            "Resource": "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.cluster_name}/${var.namespace}*"
        }
    ]
}
EOF
}




resource local_file mlflow_def {
  content = local.mlflow_def
  filename = "${path.root}/${var.argocd.path}/mlflow-defs/${var.namespace}/mlflow_def.yaml"
}


resource local_file namespace {
  content = local.namespace_def
  filename = "${path.root}/${var.argocd.path}/mlflow-namespace-${var.namespace}.yaml"
}


resource local_file mlflow {
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
        "path"           = "${var.argocd.full_path}/${var.namespace}/mlflow-defs"
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
