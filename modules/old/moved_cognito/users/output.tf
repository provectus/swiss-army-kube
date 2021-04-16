output "cloudformation_template_body" {
  value = aws_cloudformation_stack.cognito_users.template_body
}