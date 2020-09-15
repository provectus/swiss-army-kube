output "kubeconfig_filename" {
  value       = module.eks.kubeconfig_filename
  description = "kubectl config file contents for this EKS cluster."
}

output "cluster_name" {
  value       = module.eks.cluster_id
  description = "Name of eks cluster deploy"
}

output "cluster_oidc_url" {
  value       = module.eks.cluster_oidc_issuer_url
  description = "Oidc issuer url for EKS cluster"
}

output "this" {
  value       = module.eks
  description = "TBD"
}

output "workers_launch_template_ids" {
  description = "IDs of the worker launch templates."
  value       = module.eks.workers_launch_template_ids.*
}
