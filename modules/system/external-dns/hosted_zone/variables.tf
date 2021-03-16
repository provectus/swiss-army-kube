variable "hosted_zone_domain" {
  type        = string
  description = "A route53 hosted zone domain to reuse"
}

variable "hosted_zone_subdomain" {
  type        = string
  default     = null
  description = "A route53 hosted zones domains to create, linked to the hosted_zone_domain"
}

variable "aws_private" {
  type        = bool
  description = "Set true or false to use private or public infrastructure"
  default     = false
}

variable "module_depends_on" {
  default     = []
  type        = list(any)
  description = "A list of explicit dependencies"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A tags for attaching to new created AWS resources"
}

variable "vpc_id" {
  type        = string
  default     = null
  description = "An ID of the existing AWS VPC"
}