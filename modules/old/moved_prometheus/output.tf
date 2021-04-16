output "path_to_grafana_password" {
  value       = aws_ssm_parameter.grafana_password.id
  description = "A SystemManager ParemeterStore key with Grafana admin password"
}
