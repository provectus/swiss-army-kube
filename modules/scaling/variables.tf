# For depends_on queqe
variable "module_depends_on" {
  default     = []
  description = "A list of explicit dependencies for the module"
}

variable cluster_autoscaler_conf {
  default     = {}
  description = "A set of parameters to pass to Cluster Autoscaler Helm chart (see: https://github.com/kubernetes/autoscaler)"
}

variable hpa_conf {
  default     = {}
  description = "A set of parameters to pass to Horizontal Pod Autoscaler Helm chart (see: https://github.com/banzaicloud/hpa-operator)"
}

variable namespace {
  default     = "kube-system"
  description = "A namespace where Helm charts will be deployed to"
}

variable cluster_name {
  type        = string
  description = "The name of the cluster the charts will be deployed to"
}

variable hpa_enabled {
  default     = true
  description = "Whether to deploy Horizontal Pod Autoscaler chart"
}

variable cluster_autoscaler_enabled {
  default     = true
  description = "Whether to deploy Cluster Autoscaler chart"
}

variable cluster_autoscaler_chart_version {
  default     = "7.2.2"
  description = "Version of Cluster Autoscaler chart"
}

variable hpa_chart_version {
  default     = "0.2.4"
  description = "Version of Horizontal Pod Autoscaler chart"
}
