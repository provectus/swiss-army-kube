# For depends_on queqe
variable "module_depends_on" {
  default = []
}
variable cluster_name {
  type = string
}
variable vpc_id {
  type = string
}
variable subnet_cidrs {
  type = list(string)
}
variable domain {
  type = string
}
variable clients {
  type = list(string)
}