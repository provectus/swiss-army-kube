# For depends_on queqe
variable "module_depends_on" {
  default = []
}

variable "namespace" {
  type        = string
  default     = ""
  description = "A name of the existing namespace"
}

variable "namespace_name" {
  type        = string
  default     = "logging"
  description = "A name of namespace for creating"
}

variable "config_path" {
  description = "location of the kubeconfig file"
  default     = "~/.kube/config"
}

variable "cluster_name" {
  type        = string
  default     = null
  description = "A name of the Amazon EKS cluster"
}

variable "elastic_chart_version" {
  type        = string
  description = "A Helm Chart version"
  default     = "7.10.1"
}

variable "kibana_chart_version" {
  type        = string
  description = "A Helm Chart version"
  default     = "7.10.1"
}

variable "filebeat_chart_version" {
  type        = string
  description = "A Helm Chart version"
  default     = "7.10.1"
}

variable "domains" {
  description = "domain name for ingress"
  default     = "example.com"
}

variable "argocd" {
  type        = map(string)
  description = "A set of values for enabling deployment through ArgoCD"
  default     = {}
}

variable "filebeat_conf" {
  type        = map(string)
  description = "A custom configuration for deployment"
  default     = {}
}

variable "kibana_conf" {
  type        = map(string)
  description = "A custom configuration for deployment"
  default     = {}
}

variable "elastic_conf" {
  type        = map(string)
  description = "A custom configuration for deployment"
  default     = {}
}

variable "efk_oauth2_domain" {
  type        = string
  description = "Domain name for Google auth"
  default     = ""
}

variable "elasticReplicas" {
  type        = string
  description = "Number of elasticsearch nodes"
  default     = "3"
}

variable "elasticMinMasters" {
  type        = string
  description = "Number of minimum elasticsearch master nodes. Keep this number low or equals that Replicas"
  default     = "2"
}

variable "elasticDataSize" {
  type        = string
  description = "Request pvc size for elastic volume data size"
  default     = "30Gi"
}