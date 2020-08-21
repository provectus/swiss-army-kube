output "path_to_grafana_password" {
  value = aws_ssm_parameter.grafana_password.id
}