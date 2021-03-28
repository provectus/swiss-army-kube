data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

module "iam_assumable_role" {
  depends_on = [aws_iam_policy.this]
  source     = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version    = "3.0"

  for_each = { for pd in var.kubeflow_pod-defaults : pd.name => pd }

  trusted_role_arns                 = [var.external_secrets_deployment_role_arn]
  create_role                       = true
  role_name                         = "${var.cluster_name}_${each.value.namespace}_${each.value.name}_ext-secret_pod"
  role_requires_mfa                 = false
  custom_role_policy_arns           = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.cluster_name}_${each.value.namespace}_${each.value.name}_ext-secret_pod"]
  number_of_custom_role_policy_arns = 1
  tags                              = var.tags
}

resource "aws_iam_policy" "this" {
  for_each = { for pd in var.kubeflow_pod-defaults : pd.name => pd }
  name     = "${var.cluster_name}_${each.value.namespace}_${each.value.name}_ext-secret_pod"
  policy   = <<EOT
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
            "Resource": "*"
        }
    ]
}
EOT
}


resource "local_file" "kubeflow_pod-defaults" {
  depends_on = [module.iam_assumable_role]

  for_each = { for pd in var.kubeflow_pod-defaults : pd.name => pd }
  content  = <<EOT

apiVersion: 'kubernetes-client.io/v1'
kind: ExternalSecret
metadata:
  name: ${each.value.name}
  namespace: ${each.value.namespace}
spec:
  backendType: secretsManager
  roleArn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.cluster_name}_${each.value.namespace}_${each.value.name}_ext-secret_pod
  data:
    - key: ${each.value.secret}
      name: ${each.value.name}    
---
apiVersion: "kubeflow.org/v1alpha1"
kind: PodDefault
metadata:
  name: ${each.value.name}
  namespace: ${each.value.namespace}
spec:
 selector:
  matchLabels:
    git-config: "true"
 desc: "Add Git Credentials"
 volumeMounts:
 - name: git
   mountPath: /home/git
 volumes:
 - name: git
   secret:
    secretName: ${each.value.name}
EOT
  filename = "${path.root}/${var.argocd.path}/profiles/profile-${each.value.namespace}-${each.value.name}.yaml"
}