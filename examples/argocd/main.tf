data "aws_eks_cluster" "cluster" {
  name = module.kubernetes.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.kubernetes.cluster_name
}

locals {
  environment  = "dev"
  project      = "EDUCATION"
  cluster_name = "sak-argocd"
  tags = {
    environment = local.environment
    project     = local.project
  }
}

module "network" {
  source = "../../modules/network"

  availability_zones = ["us-west-2a", "us-west-2b"]
  environment        = local.environment
  project            = local.project
  cluster_name       = local.cluster_name
  network            = 10
}

module "kubernetes" {
  source = "../../modules/kubernetes"

  environment        = local.environment
  project            = local.project
  availability_zones = ["us-west-2a", "us-west-2b"]
  cluster_name       = local.cluster_name
  cluster_version    = "1.16"
  vpc_id             = module.network.vpc_id
  subnets            = module.network.private_subnets
  admin_arns         = []
  user_arns          = []
  #On-demand
  on_demand_common_max_cluster_size = 5
  on_demand_common_min_cluster_size = 1
  on_demand_common_desired_capacity = 1
  on_demand_common_instance_type    = ["m5.large", "m5.xlarge", "m5.2xlarge"]

  #Spot
  spot_max_cluster_size = 5
  spot_min_cluster_size = 0
  spot_desired_capacity = 1
  spot_instance_type    = ["m5.large", "m5.xlarge", "m5.2xlarge"]
}

module "argocd" {
  module_depends_on = [module.network.vpc_id, module.kubernetes.cluster_name]
  source            = "../../modules/cicd/argo/modules/cd"

  branch        = "feature-argocd-module"
  owner         = "provectus"
  repository    = "swiss-army-kube"
  cluster_name  = module.kubernetes.cluster_name
  chart_version = "2.7.4"
  path_prefix   = "examples/argocd/"
  apps_dir      = "applications"
}
