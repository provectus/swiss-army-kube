output "zone_id" {
  value       = local.zone_id
  description = "An ID of the created/reused Route53 zone"
}

output "domain" {
  value       = local.domain
  description = "An domain of the created/reused Route53 zone"
}
