variable "cluster_name" {
  default = "swiss-army-dkharlamov"
}

variable "region" {
  default = "eu-north-1"
}

variable "availability_zones" {
  default = ["eu-north-1a", "eu-north-1b"]
}

variable "zone_id" {
  default = "Z02149423PVQ0YMP19F13"
}

variable "environment" {
  default = "dev"
}

variable "project" {
  default = "EDUCATION"
}

variable "domain_name" {
  default = "edu.provectus.io"
}

variable "argocd" {
  default = {
    repository = "swiss-army-kube"
    branch     = "feature/kubernetes-1.18"
    owner      = "akastav"
  }
}
