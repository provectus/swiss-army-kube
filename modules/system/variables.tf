variable "namespace_name" {
  default = "kube-system"
}

variable "cluster_name" {
  type = string
}


variable "domain" {
  type = string
}


variable "cert_manager" {
  default = {
    enabled    = true
    parameters = {}
  }
}

variable "external_dns" {
  default = {
    enabled    = true
    parameters = {}
  }
}

variable "nginx_ingress" {
  default = {
    enabled    = true
    parameters = {}
  }
}
