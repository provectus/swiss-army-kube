module "iam_assumable_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v3.6.0"
  count                         = local.create_role ? 1 : 0
  create_role                   = true
  role_name                     = "${local.cluster_name}_external-secrets"
  provider_url                  = replace(var.cluster_oidc_url, "https://", "")
  role_policy_arns              = local.role_policy_arns
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.namespace}:external_secrets"] //TODO dynamically get service account name and set it here. Currently all service accounts in kube-system will be able to assume this role
  tags                          = var.tags
}

resource "aws_iam_policy" "this" {
  count  = local.create_full_access_policy ? 1 : 0
  name   = "${local.cluster_name}_external-secrets-full-access"
  policy = <<-EOT
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
            "Resource": "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${local.cluster_name}*"
        }

    ]
}
EOT
}

