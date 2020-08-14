output "pipeline_runner" {
  value = aws_iam_role.this
}

output "path_to_db_password" {
  value = aws_ssm_parameter.rds_password.id
}