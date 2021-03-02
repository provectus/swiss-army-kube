resource "aws_iam_role" "external_secrets" {
  count = var.chart_values != "" || var.aws_assume_role_arn != "" ? 0 : 1
  name  = "${local.cluster_name}_external-secrets"
  tags  = var.tags

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${var.cluster_output.oidc_provider_arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
           "${replace(var.cluster_output.cluster_oidc_issuer_url, "https://", "")}:sub": "system:serviceaccount:${var.namespace}:*"
        }
      }
    }
  ]
}
EOF
}


locals {

  created_role_arn = var.chart_values != "" || var.aws_assume_role_arn != "" ? "" : aws_iam_role.external_secrets[0].arn

  full_access_policy = <<-EOF
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
        },
        {
            "Sid": "RoleAssume",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "${local.created_role_arn}"
        }
    ]
}
  EOF 

  restricted_access_policy = <<-EOF
{
  "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "RoleAssume",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "${local.created_role_arn}"
        }
    ]
}
  EOF 
}
resource "aws_iam_role_policy" "external_secrets_access" {
  count = var.chart_values != "" || var.aws_assume_role_arn != "" ? 0 : 1
  name  = "${local.cluster_name}-external-secrets-full-access"
  role  = aws_iam_role.external_secrets[count.index].id
  policy = var.secret_manager_full_access ? local.full_access_policy : local.restricted_access_policy
}

