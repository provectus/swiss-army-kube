data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "3.0"
  count   = var.external_secrets_secret_role_arn == "" ? 1 : 0

  trusted_role_arns                 = [var.external_secrets_deployment_role_arn]
  create_role                       = true
  role_name                         = "${var.cluster_name}_${var.namespace}_external-secret_pod-default"
  role_requires_mfa                 = false
  custom_role_policy_arns           = [aws_iam_policy.this[0].arn]
  number_of_custom_role_policy_arns = 1
  tags = var.tags
}

resource "aws_iam_policy" "this" {
  count = var.external_secrets_secret_role_arn == "" ? 1 : 0
  name  = "${var.cluster_name}_${var.namespace}_external-secret_pod-default"
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
            "Resource": "*"
        }
    ]
}
EOT
}


resource local_file kubeflow_pod-defaults {
  
#role_to_assume_arn = var.external_secrets_secret_role_arn == "" ? module.iam_assumable_role[0].this_iam_role_arn : var.external_secrets_secret_role_arn
for_each = {for pd in var.kubeflow_pod-defaults: pd.name => pd}
content = <<EOT

apiVersion: 'kubernetes-client.io/v1'
kind: ExternalSecret
metadata:
  name: ${each.value.name}
  namespace: ${each.value.namespace}
spec:
  backendType: secretsManager
  roleArn: ${module.iam_assumable_role[0].this_iam_role_arn}
  dataFrom:
    - ${each.value.secret} 
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
  filename = "${path.root}/${var.argocd.path}/profiles/profile-${each.value.namespace}-${each.value.name}.yaml" # TODO, this is a hack to make sure the poddefault is rolled out with the Profiles. Should be improved later!

  #content = local.pod_default_def
  #filename = "${path.root}/${var.argocd.path}/profiles/profile-${var.namespace}-${var.name}.yaml" # TODO, this is a hack to make sure the poddefault is rolled out with the Profiles. Should be improved later!

}