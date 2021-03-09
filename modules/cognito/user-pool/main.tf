resource aws_cognito_user_pool this {
  name = var.cluster_name
  admin_create_user_config {
    invite_message_template {
      email_message = var.invite_template.email_message
      email_subject = var.invite_template.email_subject
      sms_message   = var.invite_template.sms_message
    }
  }
  tags = var.tags

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

}

resource aws_cognito_user_pool_domain this {
  domain          = "auth.${var.domain}"
  certificate_arn = module.acm_certificate.arn   #var.acm_arn
  user_pool_id    = aws_cognito_user_pool.this.id
}

resource aws_route53_record this {
  name    = aws_cognito_user_pool_domain.this.domain
  type    = "A"
  zone_id = var.zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_cognito_user_pool_domain.this.cloudfront_distribution_arn
    zone_id                = "Z2FDTNDATAQYW2"
  }
}

resource aws_route53_record root {
  name    = var.domain
  type    = "A"
  zone_id = var.zone_id
  ttl     = 60
  records = ["127.0.0.1"]
}

module acm_certificate {

  source = "../../acm-certificate"

  existing_acm_arn          = var.acm_arn   # var.loadbalancer_acm_arn
  self_sign_acm_certificate = var.self_sign_acm_certificate
  domain_name               = "auth.${var.domain}"
  subject_alternative_names = ["*.${var.domain}"]
  zone_id                   = var.zone_id
  validate_certificate      = true
  tags                      = var.tags
  aws_region                = "us-east-1"

}

