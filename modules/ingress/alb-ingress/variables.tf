# For depends_on queqe
variable "module_depends_on" {
  default = []
}

variable "cluster_name" {
  description = "Name of the kubernetes cluster"
}

variable "domains" {
  description = "domain name for ingress"
}

variable "vpc_id" {
  description = "domain name for ingress"
}

variable "aws_region" {
  description = "Name the aws region (us-central-1, us-west-2 and etc.)"
}

variable "config_path" {
  description = "location of the kubeconfig file"
  default     = "~/.kube/config"
}
