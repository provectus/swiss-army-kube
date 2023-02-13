output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "private_subnets_cidr_blocks" {
  value = module.vpc.private_subnets_cidr_blocks
}

output "vpc" {
  value = module.vpc
}

output "cluster_name" {
  value       = module.eks.cluster_id
  description = "Name of eks cluster deploy"
}

output "cluster_oidc_url" {
  value       = module.eks.cluster_oidc_issuer_url
  description = "Oidc issuer url for EKS cluster"
}

output "cluster_output" {
  value = {
    "cluster_oidc_issuer_url" = module.eks.cluster_oidc_issuer_url,
    "cluster_id"              = module.eks.cluster_id
  }
}

output "this" {
  value       = module.eks
  description = "TBD"
}