output "kubeconfig_filename" {
  value       = module.eks.kubeconfig_filename
  description = "kubectl config file contents for this EKS cluster."
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_id" {
  value = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_ca" {
  description = "CA kubernetes cluster"
  value       = data.aws_eks_cluster.cluster.certificate_authority.0.data
}

output "cluster_token" {
  description = "Token kubernetes cluster"
  value       = data.aws_eks_cluster_auth.cluster.token
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region."
  value       = var.region
}
