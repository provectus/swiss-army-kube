output "security_groups" {
  description = "Security groups ids with configured rules for accessing VPN traffic"
  value       = flatten(aws_ec2_client_vpn_network_association.this[*].security_groups)
}
