locals {
  tags = {
    environment = var.environment
    project     = var.project
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.kubernetes.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.kubernetes.cluster_name
}

module "network" {
  source = "../modules/network"

  availability_zones = var.availability_zones
  environment        = var.environment
  project            = var.project
  cluster_name       = var.cluster_name
  network            = var.network
}

module "kubernetes" {
  // TODO: change to main SAK repo
  source             = "../modules/kubernetes"
  availability_zones = var.availability_zones
  environment        = var.environment
  project            = var.project
  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  vpc_id             = module.network.vpc_id
  subnets            = module.network.private_subnets
  admin_arns         = var.admin_arns
  user_arns          = var.user_arns
  #On-demand
  on_demand_common_max_cluster_size               = var.on_demand_common_max_cluster_size
  on_demand_common_min_cluster_size               = var.on_demand_common_min_cluster_size
  on_demand_common_desired_capacity               = var.on_demand_common_desired_capacity
  on_demand_common_instance_type                  = var.on_demand_common_instance_type
  on_demand_common_allocation_strategy            = var.on_demand_common_allocation_strategy
  on_demand_common_base_capacity                  = var.on_demand_common_base_capacity
  on_demand_common_percentage_above_base_capacity = var.on_demand_common_percentage_above_base_capacity
  on_demand_common_asg_recreate_on_change         = var.on_demand_common_asg_recreate_on_change
  #Spot
  spot_max_cluster_size       = var.spot_max_cluster_size
  spot_min_cluster_size       = var.spot_min_cluster_size
  spot_desired_capacity       = var.spot_desired_capacity
  spot_instance_type          = var.spot_instance_type
  spot_instance_pools         = var.spot_instance_pools
  spot_asg_recreate_on_change = var.spot_asg_recreate_on_change
  spot_allocation_strategy    = var.spot_allocation_strategy
  spot_max_price              = var.spot_max_price
  #CPU
  on_demand_cpu_max_cluster_size               = var.on_demand_cpu_max_cluster_size
  on_demand_cpu_min_cluster_size               = var.on_demand_cpu_min_cluster_size
  on_demand_cpu_desired_capacity               = var.on_demand_cpu_desired_capacity
  on_demand_cpu_instance_type                  = var.on_demand_cpu_instance_type
  on_demand_cpu_allocation_strategy            = var.on_demand_cpu_allocation_strategy
  on_demand_cpu_base_capacity                  = var.on_demand_cpu_base_capacity
  on_demand_cpu_percentage_above_base_capacity = var.on_demand_cpu_percentage_above_base_capacity
  on_demand_cpu_asg_recreate_on_change         = var.on_demand_cpu_asg_recreate_on_change
  #GPU
  on_demand_gpu_max_cluster_size               = var.on_demand_gpu_max_cluster_size
  on_demand_gpu_min_cluster_size               = var.on_demand_gpu_min_cluster_size
  on_demand_gpu_desired_capacity               = var.on_demand_gpu_desired_capacity
  on_demand_gpu_instance_type                  = var.on_demand_gpu_instance_type
  on_demand_gpu_allocation_strategy            = var.on_demand_gpu_allocation_strategy
  on_demand_gpu_base_capacity                  = var.on_demand_gpu_base_capacity
  on_demand_gpu_percentage_above_base_capacity = var.on_demand_gpu_percentage_above_base_capacity
  on_demand_gpu_asg_recreate_on_change         = var.on_demand_gpu_asg_recreate_on_change
}
