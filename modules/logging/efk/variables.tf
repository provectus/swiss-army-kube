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

variable "logstash" {
  description = "logstash"
  default     = "false"
}

variable "filebeat" {
  description = "Enable filebeat"
  default     = "true"
}

variable "elasticsearch-curator" {
  description = "Enable elasticsearch-curator"
  default     = "true"
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

variable "efk_oauth2_domain" {
  description = "oauth2 domain for EFK"
  default     = ""
}

variable "cluster_name" {
  type        = string
  description = "Name of the kubernetes cluster"
  default     = "test"
}
