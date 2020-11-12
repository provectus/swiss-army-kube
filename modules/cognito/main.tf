resource aws_cognito_user_pool this {
  name = var.cluster_name
}

resource aws_cognito_user_pool_domain this {
  domain          = "auth.${var.domain}"
  certificate_arn = module.cognito_acm.this_acm_certificate_arn
  user_pool_id    = aws_cognito_user_pool.this.id
}

# Z2FDTNDATAQYW2 is always the hosted zone ID when you create an alias record
# that routes traffic to a CloudFront distribution.
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

# AWS Cognito expects existing of DNS record that match with Route53 hosted zone
resource aws_route53_record root {
  name    = var.domain
  type    = "A"
  zone_id = var.zone_id
  ttl     = 60
  records = ["127.0.0.1"]
}

module cognito_acm {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"
  providers = {
    aws = aws.cognito
  }

  domain_name          = "auth.${var.domain}"
  zone_id              = var.zone_id
  validate_certificate = true
  tags                 = var.tags
}

# AWS Cognito uses the N.Virginia region to deploying its own CDN system,
# that a reason why we should create ACM certificates it that zone
provider aws {
  alias  = "cognito"
  region = "us-east-1"
}
