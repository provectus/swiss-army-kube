variable "region" {
  default     = "eu-north-1"
  type        = string
  description = "Set default region"
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

variable "environment" {
  default     = "dev"
  type        = string
  description = "A value that will be used in annotations and tags to identify resources with the `Environment` key"
}

variable "project" {
  default     = "EDUCATION"
  type        = string
  description = "A value that will be used in annotations and tags to identify resources with the `Project` key"
}

variable "cluster_name" {
  default     = "swiss-army"
  type        = string
  description = "A name of the Amazon EKS cluster"
}

variable "mainzoneid" {
  default     = ""
  type        = string
  description = "An ID of the root Route53 zone for creating sub-domains"
}

variable "branch" {
  type        = string
  default     = ""
  description = "A GitHub reference"
}

variable "repository" {
  type        = string
  default     = ""
  description = "A GitHub repository wich would be used for IaC needs"
}

variable "owner" {
  type        = string
  default     = ""
  description = "An owner of GitHub repository"
}