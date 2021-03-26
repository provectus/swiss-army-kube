variable "module_depends_on" {
  default = []
}

variable "s3_bucket_name" {
  type        = string
  description = "VPC id"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}


variable "tags" {
  type        = map(string)
  description = "Tags to add to AWS resources"
  default     = {}
}

variable "trusted_role_arns" {
  type        = list(any)
  description = "ARNs of roles that are allowed to assume the role for read/write access to the S3 bucket"
  default     = []
}
