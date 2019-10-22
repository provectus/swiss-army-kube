variable "namespace_name" {
  default = "kube-system"
}

variable "cluster_name" {
  type = "string"
}

variable "cluster_autoscaler" {
   default = {
     enabled = true
     parameters []
   }
}
