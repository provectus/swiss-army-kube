# For depends_on queqe
variable "module_depends_on" {
  default = []
}

variable "config_path" {
  description = "location of the kubeconfig file"
  default     = "~/.kube/config"
}

variable "domain" {
  description = "domain name for ingress"
}

variable "elasticDataSize" {
  description = "Size of pvc for elastic data"
  default     = "30Gi"
}
