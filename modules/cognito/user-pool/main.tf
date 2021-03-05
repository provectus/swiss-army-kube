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
  certificate_arn = local.acm_arn
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


locals {
 
  create_acm_certificate = var.acm_arn == "" && !var.self_sign_acm_certificate
  create_self_signed_acm_certificate = var.acm_arn == "" && var.self_sign_acm_certificate     
  
  //if ARN of existing certificate provided, use that. If not either create a normal ACM certificate, or create a self-signed one
  acm_arn = var.acm_arn != "" ? var.acm_arn : (local.create_acm_certificate ? module.acm[0].this_acm_certificate_arn : aws_acm_certificate.self_signed_cert[0].arn)

  depends_on = [aws_acm_certificate.self_signed_cert]
}

module acm {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"

   count = local.create_acm_certificate ? 1 : 0  //only create if an existing ACM certificate hasn't been provided and not creating a self-signed cert


  domain_name          = "auth.${var.domain}"
  zone_id              = var.zone_id
  validate_certificate = true

  providers = {
    aws = aws.cognito
  }

  tags = var.tags
}

provider aws {
  alias  = "cognito"
  region = "us-east-1"
}


# import existing
resource "tls_private_key" "self_signed_cert" {
  count = local.create_acm_certificate ? 1 : 0
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "self_signed_cert" {
  count = local.create_acm_certificate ? 1 : 0
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.self_signed_cert[0].private_key_pem

  subject {
    common_name  = "example.com" //TODO might have to set this
    organization = "ACME Examples, Inc" //TODO might have to set this
  }

  validity_period_hours = 24000 //1000 days

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "self_signed_cert" {
  count = local.create_acm_certificate ? 1 : 0
  private_key      = tls_private_key.self_signed_cert[0].private_key_pem
  certificate_body = tls_self_signed_cert.self_signed_cert[0].cert_pem
}

