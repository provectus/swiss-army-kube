terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = ">=2.58"
  region  = var.aws_region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = ">=1.11.1"
}

provider "helm" {
  version = "1.0.0"

  kubernetes {
    config_path = module.kubernetes.kubeconfig_filename
  }
}

provider "random" {
  version = "~> 2.1"
}

provider "local" {
  version = "~> 1.4"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}
