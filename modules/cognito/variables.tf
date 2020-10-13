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

variable email_template {
  type        = map(string)
  description = "A template for the email with credentials"
  default = {
    email_message = null
    email_subject = null
  }
}
