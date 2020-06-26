# For depends_on queqe
variable "module_depends_on" {
  default = []
}

variable "config_path" {
  description = "location of the kubeconfig file"
  default     = "~/.kube/config"
}

variable "domains" {
  description = "domain name for ingress"
}

variable "failed_limit" {
  description = "elasticsearch-curator failed jobs history limit"
  default     = 2
}

variable "success_limit" {
  description = "elasticsearch-curator successfull jobs history limit"
  default     = 2
}

variable "elasticDataSize" {
  description = "Size of pvc for elastic data"
  default     = "30Gi"
}
