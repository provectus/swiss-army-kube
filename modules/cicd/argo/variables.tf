variable "cluster_name" {
  type = string
}
variable "domains" {
  type = list(string)
}
variable "environment" {
  type = string
}
variable "iam_openid_provider" {
  type = any
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
