# For depends_on queqe
variable "module_depends_on" {
  default = []
}

variable "domains" {
  description = "domain name for ingress"
}

variable "jenkins_password" {
  description = "Password for jenkins admin"
  default     = "password"
}

variable "config_path" {
  description = "location of the kubeconfig file"
  default     = "~/.kube/config"
}
