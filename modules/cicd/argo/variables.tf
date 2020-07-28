variable "cluster_name" {
  type        = string
  description = "Name of the kubernetes cluster"
  default     = "test"
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
