module acm {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"

  create_certificate  = var.create_certificate
  domain_name          = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  zone_id              = var.zone_id
  validate_certificate = var.validate_certificate

  tags = var.tags
}


