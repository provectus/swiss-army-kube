output "fsx_subnet_id" {
  value = local.subnet
}

output "fsx_security_group_id" {
  value = aws_security_group.fsx.id
}
