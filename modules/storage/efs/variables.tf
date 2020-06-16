# For depends_on queqe
variable "module_depends_on" {
  default = []
}

variable "vpc" {
  type = any
}
variable "cluster_name" {
  type = string
}
