# For depends_on queqe
variable "depends_on" {
  default = []
}

variable "cluster_name" {
  description = "Name of the kubernetes cluster"
}

variable "config_path" {
  description = "location of the kubeconfig file"
  default     = "~/.kube/config"
}
