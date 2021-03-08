//output pool_arn {
//  value = local.loadbalancer_acm_arn
//}

output aws_acm_certificate {
  value = aws_acm_certificate.self_signed_cert[0]
}

output loadbalancer_acm_arn {
  value = local.loadbalancer_acm_arn
}
