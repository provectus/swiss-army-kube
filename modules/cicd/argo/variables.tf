variable "cluster_name" {
  type = string
}
variable "domains" {
  type = list(string)
}
variable "environment" {
  type = string
}
variable "project" {
  type = string
}
variable "namespace" {
  default = "argo"
}
variable "install_cd" {
  default = true
}
variable "install_events" {
  default = true
}
variable "install_workflows" {
  default = true
}
variable "module_depends_on" {
  default = []
}

variable "cluster_oidc_url" {
  type = string
}