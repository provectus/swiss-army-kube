output "kubeconfig_filename" {
  value       = module.eks.kubeconfig_filename
  description = "kubectl config file contents for this EKS cluster."
}

