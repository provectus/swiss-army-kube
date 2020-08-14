# Route53
output "route53_zone" {
  value = module.system.route53_zone
}

# Kubernetes
output "cluster_name" {
  value = module.kubernetes.cluster_name
}

output "kubeconfig_filename" {
  value = module.kubernetes.kubeconfig_filename
}

output "path_to_db_password" {
  value = module.kubeflow.path_to_db_password
}