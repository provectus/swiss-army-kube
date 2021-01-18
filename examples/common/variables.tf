variable "region" {
  default     = "eu-north-1"
  type        = string
  description = "Set default region"
}

variable "cluster_name" {
  default     = "swiss-army"
  type        = string
  description = "A name of the Amazon EKS cluster"
}

variable "availability_zones" {
  default     = ["eu-north-1a", "eu-north-1b"]
  type        = list(any)
  description = "Availability zones for project"
}

variable "domains" {
  type        = list(string)
  default     = ["edu.provectus.io"]
  description = "A list of domains to use for ingresses"
}

variable "cert_manager_email" {
  type        = string
  default     = "test@example.com"
  description = "Email to cert-manager"
}

variable "mainzoneid" {
  type        = string
  default     = ""
  description = "An ID of the root Route53 zone for creating sub-domains"
}
