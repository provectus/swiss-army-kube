# For depends_on queqe
variable "module_depends_on" {
  default = []
}

variable "cluster_name" {
  type        = string
  description = "Name of the kubernetes cluster"
  default     = "test"
}

variable "aws_private" {
  type        = string
  description = "Use private or public infrastructure"
  default     = "true"
}

variable "domains" {
  description = "domain name for ingress"
}

variable "config_path" {
  description = "location of the kubeconfig file"
  default     = "~/.kube/config"
}

variable "github-auth" {
  description = "Trigger for enable or disable deploy oauth2-proxy"
}

variable "github-client-id" {
  default     = ""
  description = "Client id for auth github (create it https://github.com/settings/applications/new)"
}

variable "github-client-secret" {
  default     = ""
  description = "Client secrets"
}

variable "cookie-secret" {
  default     = ""
  description = "random_string make gen command python -c 'import os,base64; print base64.b64encode(os.urandom(16))'"
}

variable "github-org" {
  default     = ""
  description = "Github organization"
}

#Ingress google auth settings
variable "google-auth" {
  description = "Enables Google auth"
  default     = false
}

variable "google-client-id" {
  description = "Client ID for Google auth"
  default     = ""
}

variable "google-client-secret" {
  description = "Client secret for Google auth"
  default     = ""
}

variable "google-cookie-secret" {
  default     = ""
  description = "random_string make gen command python -c 'import os,base64; print base64.b64encode(os.urandom(16))'"
}