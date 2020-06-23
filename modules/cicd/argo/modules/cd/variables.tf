# For depends_on queqe
variable "module_depends_on" {
  default = []
}

variable "domains" {
  description = "domain name for ingress"
}

variable "cd_conf" {
  default = {}
}

variable "namespace" {
  default = "argo-cd"
}
