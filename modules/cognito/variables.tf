variable zone_id {
  type = string
  description = "Default zone id for root domain"
}

variable domain {
  type = string
}

variable cluster_name {
  type        = string
  default     = null
  description = "A name of the Amazon EKS cluster"
}

variable tags {
  type        = map(string)
  default     = {}
  description = "A tags for attaching to new created AWS resources"
}
