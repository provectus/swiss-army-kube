variable zone_id {
  type = string
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
  description = "A set of tags"
  default     = {}
}
