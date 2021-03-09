
output arn {
  value = local.reuse_existing_acm_arn ? var.existing_acm_arn : (var.create_self_signed_acm_certificate ? aws_acm_certificate.self_signed_cert[0].arn : module.acm_certificate[0].this_acm_certificate_arn)
}
