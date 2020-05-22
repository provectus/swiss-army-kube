output "kubernetes_service_account" {
  value = "${kubernetes_service_account.tiller}"
}

output "cert-manager" {
  value = "${helm_release.cert-manager}"
}

output "oidc_arn" {
  value = "${aws_iam_openid_connect_provider.cluster.arn}"
}