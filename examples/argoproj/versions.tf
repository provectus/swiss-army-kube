terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.20"
    }
    external = {
      source  = "hashicorp/external"
      version = "1.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "1.3.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "1.13.3"
    }
    local = {
      source  = "hashicorp/local"
      version = "1.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "2.1.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
  required_version = ">= 0.14"
}
