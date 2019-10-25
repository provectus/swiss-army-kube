provider "aws" {}

module "infra" {
  source        = "../../modules/infrastructure"
  cluster_name  = "sak"
  cluster_zones = ["us-east-1a", "us-east-1b"]
  network       = "10.250.0.0/16"
  spot_price    = 0.5
}

data "aws_eks_cluster" "current" {
  name = module.infra.eks.cluster_id
}

data "aws_eks_cluster_auth" "current" {
  name = module.infra.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.current.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.current.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.current.token
  load_config_file       = false
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "terraform-tiller"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "terraform-tiller"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.tiller.metadata.0.name
    namespace = "kube-system"
  }
}

provider "helm" {
  install_tiller  = true
  namespace       = "kube-system"
  service_account = kubernetes_service_account.tiller.metadata.0.name
  kubernetes {
    host                   = data.aws_eks_cluster.current.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.current.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.current.token
    load_config_file       = false
  }
}

module "scaling" {
  source        = "../../modules/scaling"
  cluster_name  = module.infra.eks.cluster_id
}

module "monitoring" {
  source        = "../../modules/monitoring"
  cluster_name  = module.infra.eks.cluster_id
}
