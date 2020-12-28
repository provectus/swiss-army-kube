output "pool_arn" {
  description = "An ARN of the new created AWS Cognito User Pool"
  value       = aws_cognito_user_pool.this.arn
}

output "pool_id" {
  description = "An ID of the new created AWS Cognito User Pool"
  value       = aws_cognito_user_pool.this.id
}

output "domain" {
  description = "A custom domain name of the AWS Cognito endpoint"
  value       = aws_cognito_user_pool_domain.this.domain
}
