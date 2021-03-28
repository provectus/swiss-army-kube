output "s3_user_arn" {
  value = aws_iam_user.s3_user.arn
}

output "s3_role_arn" {
  value = module.s3_role.this_iam_role_arn
}


output "s3_user_access_key" {
  value = {
    id     = aws_iam_access_key.s3_user.id
    secret = aws_iam_access_key.s3_user.secret
  }
}
output "s3_bucket_arn" {
  value = aws_s3_bucket.kubeflow.arn
}


output "s3_bucket_name" {
  value = aws_s3_bucket.kubeflow.bucket
}