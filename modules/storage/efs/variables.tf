# For depends_on queqe
variable "module_depends_on" {
  default     = []
  type        = list(any)
  description = "A list of explicit dependencies"
}

variable "vpc" {
  type = any
}
variable "cluster_name" {
  type        = string
  default     = null
  description = "A name of the Amazon EKS cluster"
}
