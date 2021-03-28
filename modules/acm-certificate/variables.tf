
variable "domain_name" {
  type        = string
  description = "A domain name for which the certificate should be issued"
  default     = ""
}

variable "subject_alternative_names" {
  type        = list(string)
  description = "A list of domains that should be SANs in the issued certificate"
  default     = []
}

variable "zone_id" {
  type = string
}

variable "validate_certificate" {
  type    = bool
  default = true
}

variable "tags" {
  type        = map(string)
  description = "A set of tags"
  default     = {}
}

variable "existing_acm_arn" {
  type        = string
  description = "The ARN of an ACM certificate to attach to the Load Balancer"
  default     = ""
}

variable "self_sign_acm_certificate" {
  type        = bool
  description = "Set to true in order to create a self-signed ACM certificates instead of letting ACM create and validate them"
  default     = false
}

variable "aws_region" {
  type        = string
  description = "Region in which to create the certificate"
  default     = ""

}

variable "self_signed_certificate_validity_period" {
  type        = number
  description = "Number of hours the self-signed certificate should be valid"
  default     = 2400 //100 days
}