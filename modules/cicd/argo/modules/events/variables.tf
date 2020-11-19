variable module_depends_on {
  default     = []
  type        = list(any)
  description = "A list of explicit dependencies"
}

variable events_conf {
  default = {}
}

variable namespace {
  type        = string
  default     = null
  description = "A name of the existing namespace"
}
