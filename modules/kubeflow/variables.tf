# For depends_on queqe
variable "module_depends_on" {
  default = []
}

variable "vpc" {
  type = any
}

variable "cluster_name" {
  type = string
}

variable "cluster" {
  type = any
}

variable "artifacts" {
  type = any
}

variable "config_path" {
  description = "location of the kubeconfig file"
  default     = "~/.kube/config"
}
