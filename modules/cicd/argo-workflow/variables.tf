# For depends_on queqe
variable "module_depends_on" {
  default = []
}

variable "aws_s3_bucket" {
  description = "Bucket name in s3"
}

variable "aws_region" {
  description = "Bucket region location"
}