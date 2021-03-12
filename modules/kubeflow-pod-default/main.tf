data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "3.0"
  count   = var.external_secrets_secret_role_arn == "" ? 1 : 0

  trusted_role_arns                 = [var.external_secrets_deployment_role_arn]
  create_role                       = true
  role_name                         = "${var.cluster_name}_${var.namespace}_external-secret-${var.name}"
  role_requires_mfa                 = false
  custom_role_policy_arns           = [aws_iam_policy.this[0].arn]
  number_of_custom_role_policy_arns = 1
  tags = var.tags
}

resource "aws_iam_policy" "this" {
  count = var.external_secrets_secret_role_arn == "" ? 1 : 0
  name  = "${var.cluster_name}_${var.namespace}_external-secret--${var.name}"
  policy = <<-EOT
{
  "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:ListSecretVersionIds",
                "secretsmanager:GetSecretVagit branchlue",
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:DescribeSecret"
            ],
            "Resource": ${var.secret_arn}
        }
    ]
}
EOT
}


resource local_file pod_default_def {
  content = local.pod_default_def
  filename = "${path.root}/${var.argocd.path}/profiles/profile-${var.namespace}-${var.name}.yaml" # TODO, this is a hack to make sure the poddefault is rolled out with the Profiles. Should be improved later!

}

