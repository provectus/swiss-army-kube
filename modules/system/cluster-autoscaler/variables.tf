# For depends_on queqe
variable module_depends_on {
  default = []
}

variable autoscaler_conf {
  default = {}
}

variable namespace {
  default = "kube-system"
}

variable cluster_name {
  type = string
}

variable chart_version {
  type    = string
  default = "8.0.0"
}

variable image_tag {
  type    = string
  default = "1.17.1"
}
