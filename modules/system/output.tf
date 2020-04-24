output "cert-manager" {
  value = helm_release.cert-manager
}

output "iam_openid_provider" {
  value = aws_iam_openid_connect_provider.cluster
}
