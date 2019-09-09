output "kubeconfig_filename" {
  value       = "${module.eks.kubeconfig_filename}"
  description = "kubectl config file contents for this EKS cluster."
}

output "cluster_name" {
  value = "${module.eks.cluster_id}"
}
