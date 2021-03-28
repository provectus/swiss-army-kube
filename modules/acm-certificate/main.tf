data "aws_region" "current" {}

locals {

  reuse_existing_acm_arn             = var.existing_acm_arn != ""
  create_self_signed_acm_certificate = var.existing_acm_arn == "" && var.self_sign_acm_certificate
  create_normal_acm_certificate      = var.existing_acm_arn == "" && !var.self_sign_acm_certificate

  aws_region = var.aws_region == "" ? data.aws_region.current.name : var.aws_region

}


provider "aws" {
  alias  = "certificate"
  region = local.aws_region
}


# normal acm certificate
module "acm_certificate" {
  source  = "terraform-aws-modules/acm/aws"
  version = "v2.0"

  count                     = local.create_normal_acm_certificate ? 1 : 0
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  zone_id                   = var.zone_id
  validate_certificate      = var.validate_certificate

  providers = {
    aws = aws.certificate
  }

  tags = var.tags
}



# self-signed certificate
resource "tls_private_key" "self_signed_cert" {
  count     = local.create_self_signed_acm_certificate ? 1 : 0
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "self_signed_cert" {
  count           = local.create_self_signed_acm_certificate ? 1 : 0
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.self_signed_cert[0].private_key_pem

  subject {
    common_name  = var.domain_name
    organization = var.domain_name
  }

  validity_period_hours = var.self_signed_certificate_validity_period

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "self_signed_cert" {
  count            = local.create_self_signed_acm_certificate ? 1 : 0
  private_key      = tls_private_key.self_signed_cert[0].private_key_pem
  certificate_body = tls_self_signed_cert.self_signed_cert[0].cert_pem

  provider = aws.certificate

}