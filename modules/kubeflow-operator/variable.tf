variable branch {
  type        = string
  description = "A GitHub reference"
}

variable repository {
  type        = string
  description = "A GitHub repository that would be used for IaC needs"
}

variable cognito {
  type        = map(string)
  description = "A set of variables for enabling AWS Cognito"
  default = {
    "pool_arn"        = ""
    "client_id"       = ""
    "domain"          = ""
    "certificate_arn" = ""
  }
}

variable domain {
  type        = string
  description = "A domain name that would be assigned to Kubeflow installation"
}
