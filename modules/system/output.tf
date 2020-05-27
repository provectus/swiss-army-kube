output "cert-manager" {
  value = "${helm_release.cert-manager}"
}

output "oidc_arn" {
  value = "${aws_iam_openid_connect_provider.cluster.arn}"
}