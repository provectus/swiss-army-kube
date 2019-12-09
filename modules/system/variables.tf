# For depends_on queqe
variable "module_depends_on" {
  default = []
}

#Deploy environment name
variable "environment" {
  type        = string
  description = "Deploy environment name"
}

variable "cluster_name" {
  description = "Name of the kubernetes cluster"
}

variable "config_path" {
  description = "location of the kubeconfig file"
  default     = "~/.kube/config"
}

variable "domain" {
  description = "domain name for ingress"
}

variable "cluster_size" {
  type        = number
  description = "Number of desired instances."
}

#Cert-manager
variable "cert_manager_email" {
  type        = string
  description = "Email to cert-manager"
}

variable "cert_manager_zoneid" {
  type        = string
  description = "Route53 hosted zone ID for manage at cert-manager"
}
