output "cert-manager" {
  value = helm_release.cert-manager
}

output "oidc_arn" {
  value = var.cluster_oidc_arn
}

output "route53_zone" {
  value = aws_route53_zone.cluster
}

output "cluster_available" {
  value = null_resource.wait-eks.id
}
