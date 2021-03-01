
output external_secrets_role_arn {
    value = var.aws_assume_role_arn == "" ? var.aws_iam_role.this : aws_iam_role.external_secrets.arn
}



