output "cert-manager" {
  value = "${helm_release.cert-manager}"
}

output "oidc_arn" {
  value = "${aws_iam_openid_connect_provider.cluster.arn}"
}

output "route53_zone" {
  value = "${aws_route53_zone.cluster}"
}
