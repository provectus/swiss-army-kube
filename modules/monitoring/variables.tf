variable "namespace_name" {
  type    = "string"
  default = "monitoring"
}

variable "cluster_name" {
  type = "string"
}

variable "monitoring" {
  default = {
    enabled    = true
    parameters = {}
  }
}
