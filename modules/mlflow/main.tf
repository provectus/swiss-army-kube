

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


resource local_file mlflow_def {
  content = local.mlflow_def
  filename = "${path.root}/${var.argocd.path}/mlflow-defs/mlflow_def.yaml"
}


resource local_file namespace {
  content = local.namespace_def
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
