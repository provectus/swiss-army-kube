output "pool_arn" {
  value = aws_cognito_user_pool.this.arn
}

output "pool_id" {
  value = aws_cognito_user_pool.this.id
}

output "domain" {
  value = aws_cognito_user_pool_domain.this.domain
}
