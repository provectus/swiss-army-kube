variable "aws_region" {
  default = "us-west-2"
  type    = "string"
}

variable "cluster_name" {
  default = "dev-cluster"
  type    = "string"
}

variable "cluster_size" {
  default = "3"
  type    = "string"
}
