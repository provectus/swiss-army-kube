data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_secretsmanager_secret" "this" {
  for_each                = local.secret_data
  name                    = "${var.cluster_name}/${var.namespace}/${each.key}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each      = local.secret_data
  secret_id     = lookup(aws_secretsmanager_secret.this, each.key).id
  secret_string = each.value
}

resource "aws_secretsmanager_secret" "password" { //rds_password is a "sensitive" variable. It cannot be included in a for_each
  name                    = "${var.cluster_name}/${var.namespace}/rds_password"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "password" {
  secret_id     = aws_secretsmanager_secret.password.id
  secret_string = var.rds_password
}


module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "3.0"
  count   = var.external_secrets_secret_role_arn == "" ? 1 : 0

  trusted_role_arns                 = [var.external_secrets_deployment_role_arn]
  create_role                       = true
  role_name                         = "${var.cluster_name}_${var.namespace}_external-secrets-kubeflow"
  role_requires_mfa                 = false
  custom_role_policy_arns           = [aws_iam_policy.this[0].arn]
  number_of_custom_role_policy_arns = 1
  tags                              = var.tags
}

resource "aws_iam_policy" "this" {
  count  = var.external_secrets_secret_role_arn == "" ? 1 : 0
  name   = "${var.cluster_name}_${var.namespace}_external-secrets-kubeflow-access"
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





resource "local_file" "kubeflow_operator" {
  content = yamlencode({
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "kubeflow-operator"
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = "operators"
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = "https://github.com/kubeflow/kfctl"
        "targetRevision" = "v1.2-branch"
        "path"           = "deploy"
        "kustomize" = {
          "images" = ["aipipeline/kubeflow-operator:v1.2.0"]
        }
      }
      "syncPolicy" = {
        "syncOptions" = [
          "CreateNamespace=true"
        ]
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
      }
    }
  })
  filename = "${path.root}/${var.argocd.path}/kubeflow-operator.yaml"
}


resource "local_file" "kubeflow" {
  content = yamlencode({
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "kubeflow"
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = "kubeflow"
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = var.argocd.repository
        "targetRevision" = var.argocd.branch
        "path"           = "${var.argocd.full_path}/kfdefs"
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
  filename = "${path.root}/${var.argocd.path}/kubeflow.yaml"
}


resource "local_file" "namespace" {
  content  = local.namespace_def
  filename = "${path.root}/${var.argocd.path}/kubeflow-namespace.yaml"
}

resource "local_file" "kfdef" {
  content  = local.kfdef
  filename = "${path.root}/${var.argocd.path}/kfdefs/kfdef.yaml"
}

resource "local_file" "ingress" {
  content  = local.ingress
  filename = "${path.root}/${var.argocd.path}/kfdefs/ingress.yaml"
}

resource "local_file" "issuer" {
  content  = local.issuer
  filename = "${path.root}/${var.argocd.path}/kfdefs/issuer.yaml"
}

resource "local_file" "configs" {
  content  = local.configs
  filename = "${path.root}/${var.argocd.path}/kfdefs/configs.yaml"
}

resource "local_file" "external_secret" {
  content  = local.external_secret
  filename = "${path.root}/${var.argocd.path}/kfdefs/external-secret.yaml"
}


resource "local_file" "create_databases" {

  for_each = toset([var.db_name_pipelines, var.db_name_metadata, var.db_name_cache, var.db_name_katib])

  content = <<EOT
apiVersion: batch/v1
kind: Job
metadata:
  name: create-${each.key}-database
  namespace: ${var.namespace}
spec:
  template:
    metadata:
      annotations:
        "sidecar.istio.io/inject": "false"
    spec:
      containers:
      - name: create-${each.key}-database
        image: public.ecr.aws/v5l9k3w9/utils/mysql-db-creator:latest
        env:
        - name: HOST
          valueFrom:
            secretKeyRef:
              name: aws-storage-secret
              key: rds_host
        - name: PORT
          valueFrom:
            secretKeyRef:
              name: aws-storage-secret
              key: rds_port
        - name: USERNAME
          valueFrom:
            secretKeyRef:
              name: aws-storage-secret
              key: rds_username
        - name: PASSWORD
          valueFrom:
            secretKeyRef:
              name: aws-storage-secret
              key: rds_password
        - name: DATABASE
          value: ${each.key}

      restartPolicy: Never
  backoffLimit: 5
  EOT

  filename = "${path.root}/${var.argocd.path}/kfdefs/create-database-${each.key}.yaml"
}

