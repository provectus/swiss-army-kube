# For depends_on queqe
variable "module_depends_on" {
  default = []
}

variable "namespace_name" {
  description = "Name of the namespace where install charts"
  default     = "system"
}

variable "cluster_name" {
  description = "Name of the kubernetes cluster"
}

variable "config_path" {
  description = "location of the kubeconfig file"
  default     = "~/.kube/config"
}

variable "domains" {
  description = "domain name for ingress"
}
