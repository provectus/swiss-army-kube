# For depends_on queqe
variable "module_depends_on" {
  default = []
}

variable "cluster_name" {
  description = "Name of the kubernetes cluster"
}

variable "domain" {
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
