


data "aws_route53_zone" "domain" {
  name         = var.hosted_zone_domain
  private_zone = var.aws_private
}


resource "aws_route53_zone" "public" {
  depends_on = [
    var.module_depends_on,
  ]

  count = !var.aws_private && local.make_subdomain ? 1 : 0
  name  = var.hosted_zone_subdomain

  tags          = var.tags
  force_destroy = true
}

resource "aws_route53_zone" "private" {
  depends_on = [
    var.module_depends_on,
  ]
  count = var.aws_private && local.make_subdomain ? 1 : 0
  name  = var.hosted_zone_subdomain
  vpc {
    vpc_id = var.vpc_id
  }
  tags          = var.tags
  force_destroy = true
}

resource "aws_route53_record" "ns" {
  depends_on = [
    var.module_depends_on,
  ]
  count   = local.make_subdomain ? 1 : 0
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = var.aws_private ? aws_route53_zone.private[0].name : aws_route53_zone.public[0].name
  type    = "NS"
  ttl     = "30"

  records = [
    for num in range(4) :
    element(var.aws_private ? aws_route53_zone.private[0].name_servers : aws_route53_zone.public[0].name_servers, num)
  ]
}

locals {
  make_subdomain = var.hosted_zone_subdomain != null
  zone_id        = !local.make_subdomain ? data.aws_route53_zone.domain.zone_id : var.aws_private ? aws_route53_zone.private[0].zone_id : aws_route53_zone.public[0].zone_id
  domain         = !local.make_subdomain ? data.aws_route53_zone.domain.name : var.aws_private ? aws_route53_zone.private[0].name : aws_route53_zone.public[0].name
}