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
