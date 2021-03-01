
output external_secrets_role_arn {
    value = var.aws_assume_role_arn == "" ? var.aws_assume_role_arn : aws_iam_role.external_secrets[0].arn
}

