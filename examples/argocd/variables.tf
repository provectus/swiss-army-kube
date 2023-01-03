variable "cidr" {
  type        = string
  description = "TBD"
  default     = null
}

variable "network_delimiter" {
  type        = string
  description = "TBD"
  default     = "8"
}

variable "network" {
  type        = string
  description = "Number would be used to template CIDR 10.X.0.0/16."
  default     = "10"
}

variable "single_nat" {
  type        = bool
  description = "Use single Nat gateway or separeta for all AZ"
  default     = true
}

variable "cluster_name" {
  default     = "swiss-army-kube"
  type        = string
  description = "A name of the Amazon EKS cluster"
}

variable "region" {
  default     = "eu-north-1"
  type        = string
  description = "Set default region"
}

variable "availability_zones" {
  default     = ["eu-north-1a", "eu-north-1b"]
  type        = list(any)
  description = "Availability zones for project"
}

variable "environment" {
  default     = "dev"
  type        = string
  description = "A value that will be used in annotations and tags to identify resources with the `Environment` key"
}

variable "project" {
  default     = "SWISS"
  type        = string
  description = "A value that will be used in annotations and tags to identify resources with the `Project` key"
}

variable "domain_name" {
  default     = "swiss.sak.ninja"
  type        = string
  description = "Default domain name"
}

variable "argocd" {
  default = {
    repository = "swiss-army-kube"
    branch     = "master"
    owner      = "provectus"
  }
  type        = map(string)
  description = "A set of values for enabling deployment through ArgoCD"
}

variable "cluster_version" {
  type        = string
  description = "EKS cluster version"
  default     = "1.22"
}


variable "container_runtime" {
  type        = string
  default     = "docker"
  description = "Type of container runtime interface. Allowed values: docker/containerd"
  validation {
    condition     = can(regex("^(docker|containerd)$", var.container_runtime))
    error_message = "Must be docker or containerd."
  }
}


# enable control plane cloudwatch logging
variable "cloudwatch_logging_enabled" {
  type        = bool
  description = "Send EKS control plane logs to cloudwatch"
  default     = false
}


variable "cloudwatch_cluster_log_types" {
  type        = list(any)
  description = "log types that you want to send to cloudwatch"
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}


variable "cloudwatch_cluster_log_retention_days" {
  type        = number
  description = "logs retention period in days (1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, 0). 0 means logs will never expire."
  default     = 90
}
