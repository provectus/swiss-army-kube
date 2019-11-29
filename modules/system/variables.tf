variable "namespace_name" {
  description = "Name of namespace where install charts"
  default     = "system"
}

variable "cluster_name" {
  description = "Name of kubernetes cluster"
  default     = "example-cluster"
}

variable "config_path" {
  description = "location of kubeconfig file"
  default     = "~/.kube/config"
  
}

variable "domain" {
  description = "domain name for ingress"
  default     = "example.com"
}

