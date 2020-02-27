provider "aws" {
  version = ">= 2.33.0"
  region  = var.aws_region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "1.10.0"
}

provider "helm" {
  version         = "~> 0.10"
  install_tiller  = "true"
  service_account = module.system.kubernetes_service_account.metadata.0.name
  namespace       = module.system.kubernetes_service_account.metadata.0.namespace

  kubernetes {
    config_path = module.kubernetes.kubeconfig_filename
  }
}

provider "random" {
  version = "~> 2.1"
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}
