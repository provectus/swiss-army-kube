variable aws_private {
  type    = any
  default = false
}

variable cluster_name {
  type    = string
  default = ""
}

variable domains {
  type    = list
  default = []
}

variable environment {
  type    = string
  default = ""
}

variable mainzoneid {
  type    = string
  default = ""
}

variable module_depends_on {
  type    = list
  default = []
}

variable namespace {
  type    = string
  default = "kube-system"
}

variable project {
  type    = string
  default = ""
}

variable vpc_id {
  type    = string
  default = ""
}

