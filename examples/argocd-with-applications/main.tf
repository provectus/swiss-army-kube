data aws_eks_cluster cluster {
  name = module.kubernetes.cluster_name
}

data aws_eks_cluster_auth cluster {
  name = module.kubernetes.cluster_name
}

locals {
  environment  = "dev"
  project      = "EDUCATION"
  cluster_name = "sak-argocd-full"
  tags = {
    environment = local.environment
    project     = local.project
  }
}

module network {
  source = "../../modules/network"

  availability_zones = ["us-west-2a", "us-west-2b"]
  environment        = local.environment
  project            = local.project
  cluster_name       = local.cluster_name
  network            = 10
}

module kubernetes {
  source = "../../modules/kubernetes"

  environment        = local.environment
  project            = local.project
  availability_zones = ["us-west-2a", "us-west-2b"]
  cluster_name       = local.cluster_name
  vpc_id             = module.network.vpc_id
  subnets            = module.network.private_subnets
}

module argocd {
  module_depends_on = [module.network.vpc_id, module.kubernetes.cluster_name]
  source            = "../../modules/cicd/argo/modules/cd"

  branch       = "feature/scaling-refactoring"
  owner        = "provectus"
  repository   = "swiss-army-kube"
  cluster_name = module.kubernetes.cluster_name
  path_prefix  = "examples/argocd-with-applications/"
}

module scaling {
  source       = "../../modules/scaling"
  cluster_name = module.kubernetes.cluster_name
  argocd       = module.argocd.state
}
