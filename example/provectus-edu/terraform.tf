terraform {
  backend "s3" {
    bucket = "pv-terraform-states"
    key    = "swiss-army-kube/example/rgimadiev"
    region = "eu-west-1"
  }
}

provider "aws" {
  version = ">= 2.33.0"
  region  = "eu-west-1"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.cluster.token
  version                = "~> 1.10"
}

data "aws_eks_cluster" "cluster" {
  name = module.kubernetes.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.kubernetes.cluster_name
}

provider "helm" {
  version = "~> 1.0.0"

  kubernetes {
    config_path = module.kubernetes.this.kubeconfig_filename
  }
}
