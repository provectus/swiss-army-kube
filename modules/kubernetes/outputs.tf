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

output "oidc_provider_arn" {
  value       = module.eks.oidc_provider_arn
  description = "oidc provider url for EKS cluster"
}

# output "cluster_output" {
#   value = {
#     "cluster_oidc_issuer_url" = module.eks.cluster_oidc_issuer_url,
#     "oidc_provider_arn"       = module.eks.oidc_provider_arn,
#     "cluster_id"              = module.eks.cluster_id
#   }
# }

output "this" {
  value       = module.eks
  description = "TBD"
}

output "workers_launch_template_ids" {
  description = "IDs of the worker launch templates."
  value       = module.eks.workers_launch_template_ids.*
}

output "worker_security_group_id" {
  description = "ID of the worker security groups."
  value       = module.eks.worker_security_group_id
}

output "worker_iam_role_arn" {
  description = "default IAM role ARN for EKS worker groups"
  value       = module.eks.worker_iam_role_arn
}

