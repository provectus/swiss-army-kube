variable chart_version {
  type        = string
  description = "An ArgoCD Helm Chart version"
  default     = "2.7.0"
}

variable conf {
  type        = map(string)
  description = "A custom configuration for ArgoCD deployment"
  default     = {}
}

variable module_depends_on {
  type        = list
  default     = []
  description = "A dependency list"
}

variable branch {
  type        = string
  description = "A GitHub reference"
}

variable repository {
  type        = string
  description = "A GitHub repository wich would be used for IaC needs"
}

variable owner {
  type        = string
  description = "An owner of GitHub repository"
}

variable cluster_name {
  type        = string
  description = "A name of the EKS cluster"
}

variable domains {
  type        = list(string)
  description = "A list of domains to use"
}

variable vcs {
  type        = string
  description = ""
  default     = "github.com"
}
