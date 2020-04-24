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
