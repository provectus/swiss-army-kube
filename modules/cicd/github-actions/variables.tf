variable "argocd" {
  type        = map(string)
  description = "A set of values for enabling deployment through ArgoCD"
  default     = {}
}

variable "conf" {
  type        = map(string)
  description = "A custom configuration for deployment"
  default     = {}
}

variable "namespace" {
  type        = string
  default     = ""
  description = "A name of the existing namespace"
}

variable "namespace_name" {
  type        = string
  default     = "github-actions"
  description = "A name of namespace for creating"
}

variable "module_depends_on" {
  default     = []
  type        = list(any)
  description = "A list of explicit dependencies"
}

variable "cluster_name" {
  type        = string
  default     = null
  description = "A name of the Amazon EKS cluster"
}

variable "chart_version" {
  type        = string
  description = "A Helm Chart version"
  default     = "0.5.2"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A tags for attaching to new created AWS resources"
}

variable "github_token" {
  type        = string
  description = "A GitHub token for application"
  default     = null
  sensitive   = true
}

variable "actions_repositories" {
  type        = map(string)
  description = "describe your variable"
  default     = {}
}

variable "runner_deployment_spec" {
  type        = any
  description = "A custom Github Runner configuration"
  default = {
    "replicas" = 1
    "template" = {
      "spec" = {
        "repository"                   = "%REPOSITORY%"
        "dockerdWithinRunnerContainer" = true
        "image"                        = "summerwind/actions-runner-dind"
        "labels" = [
          "private",
        ]
        "volumeMounts" = [
          {
            "mountPath" = "/runner"
            "name"      = "runner"
          }
        ]
        "volumes" = [
          {
            "name"     = "runner"
            "emptyDir" = {}
          }
        ]
      }
    }
  }
}
