# For depends_on queqe
variable "module_depends_on" {
  default = []
}

variable "aws_private" {
  type        = string
  description = "Use private or public infrastructure"
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
  type        = string
  description = "Name of the kubernetes cluster"
  default     = "test"
}

variable "vpc_id" {
  type        = string
  description = "VPC id"
}

variable "mainzoneid" {
  type        = string
  description = "ID of main route53 zone if exist"
}

variable "config_path" {
  description = "location of the kubeconfig file"
  default     = "~/.kube/config"
}

variable "domains" {
  description = "domain name for ingress, set as coma-sepparate list"
}

#Cert-manager
variable "cert_manager_email" {
  type        = string
  description = "Email to cert-manager"
}

variable "cluster_oidc_url" {
  type        = string
  description = "OIDC EKS cluster endpoint"
  default     = "null"
}