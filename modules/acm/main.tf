
locals {

  create_self_signed_acm_certificate = var.loadbalancer_acm_arn == "" && var.self_sign_acm_certificate
  create_acm_certificate = !local.create_self_signed_acm_certificate

  loadbalancer_acm_arn = var.loadbalancer_acm_arn != "" ? var.loadbalancer_acm_arn : (var.self_sign_acm_certificate ? aws_acm_certificate.self_signed_cert[0].arn : module.acm[0].this_acm_certificate_arn)

  # depends_on = [aws_acm_certificate.self_signed_cert[0]]

}


provider aws {
  alias  = "cognito"
  region = "us-east-1"
}


module acm {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"

  create_certificate  = var.create_certificate
  domain_name          = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  zone_id              = var.zone_id
  validate_certificate = var.validate_certificate

  providers = {
    aws = aws.cognito
  }
  tags = var.tags
}



# self-signed certificate
resource "tls_private_key" "self_signed_cert" {
  count = local.create_self_signed_acm_certificate ? 1 : 0
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "self_signed_cert" {
  count = local.create_self_signed_acm_certificate ? 1 : 0
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.self_signed_cert[0].private_key_pem

  subject {
    common_name  = "learn-mlops.com" //TODO might have to set this
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
  count = local.create_self_signed_acm_certificate ? 1 : 0
  private_key      = tls_private_key.self_signed_cert[0].private_key_pem
  certificate_body = tls_self_signed_cert.self_signed_cert[0].cert_pem
}