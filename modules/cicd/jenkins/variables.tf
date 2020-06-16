# For depends_on queqe
variable "module_depends_on" {
  default = []
}

variable "domains" {
  description = "domain name for ingress"
}

variable "jenkins_password" {
  description = "Password for jenkins admin"
  default     = "password"
}

variable "config_path" {
  description = "location of the kubeconfig file"
  default     = "~/.kube/config"
}

#Deploy environment name
variable "environment" {
  type        = string
  description = "Environment Use in tags and annotations for identify EKS cluster"
}

variable "project" {
  type        = string
  description = "Project Use in tags and annotations for identify EKS cluster"
}

variable "cluster_name" {
  description = "Name of the kubernetes cluster"
}

variable "cluster_oidc_arn" {
  type        = string
  description = "OIDC EKS cluster arn"
  default     = ""
}

variable "cluster_oidc_url" {
  type        = string
  description = "OIDC EKS cluster endpoint"
  default     = ""
}

variable "agent_policy" {
  description = "Policy attached to Jenkins agents IAM role"
  default     = ""
}

variable "master_policy" {
  description = "Policy attached to Jenkins master IAM role"
  default     = ""
}