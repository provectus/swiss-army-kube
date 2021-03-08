variable zone_id {
  type = string
}

variable domain {
  type = string
}

variable cluster_name {
  type        = string
  description = "A name of the cluster"
}

variable tags {
  type        = map(string)
  description = "A set of tags"
  default     = {}
}

variable acm_arn {
  type = string
  description = "The ARN of an ACM certificate to attach to the Cognito App Domain (must be in us-east-1)"
  default = ""
}


variable self_sign_acm_certificate {
  type        = bool
  description = "Set to true in order to create a self-signed ACM certificates instead of letting ACM create and validate them"
  default     = false
}

variable create_certificate  {
  type        = bool
  description = ""
  default     = false
}

variable loadbalancer_acm_arn {
  type = string
  description = "The ARN of an ACM certificate to attach to the Load Balancer"
  default = ""
}

variable invite_template {
  type        = map(string)
  description = "A template for the invite email with credentials"
  default = {
    email_message = <<EOT
Your Swiss Army Kube username is {username} and temporary password is {####}.
EOT
    email_subject = "Your Swiss Army Kube temporary password"
    sms_message   = "Your Swiss Army Kube username is {username} and temporary password is {####}"
  }
}
