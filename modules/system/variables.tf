# For depends_on queqe
variable "module_depends_on" {
  default = []
}

#Deploy environment name
variable "environment" {
  type        = string
  description = "Environment Use in tags and annotations for identify EKS cluster"
}

variable "project" {
  type        = string
  description = "Project Use in tags and annotations for identify EKS cluster"
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

variable "cluster_oidc_url" {
  type        = string
  description = "OIDC EKS cluster endpoint"
  default     = ""
}