# Declare the data source
data "aws_availability_zones" "available" {}

data "aws_region" "current" {}

# EKS - aws kubernetes cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = ">= v7.0.0"
  cluster_version = var.cluster_version
  cluster_name    = var.cluster_name
  subnets         = var.private_subnets
  vpc_id          = var.vpc_id

  map_users = var.admin_arns

  tags = {
    Environment = var.environment
    Project     = var.project
  }

  workers_additional_policies = [
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53AutoNamingFullAccess",
    "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
  ]
  worker_groups = [
    {
      name                 = "on-demand-1"
      instance_type        = var.on_demand_instance_type
      asg_max_size         = var.on_demand_max_cluster_size
      asg_min_size         = var.on_demand_min_cluster_size
      asg_desired_capacity = var.on_demand_desired_capacity
      autoscaling_enabled  = true
      kubelet_extra_args   = "--node-labels=kubernetes.io/lifecycle=normal"
      suspended_processes  = ["AZRebalance"]
    },
    {
      name                 = "spot-1"
      spot_price           = var.spot_price
      instance_type        = var.spot_instance_type
      asg_max_size         = var.spot_max_cluster_size
      asg_min_size         = var.spot_min_cluster_size
      asg_desired_capacity = var.spot_desired_capacity
      autoscaling_enabled  = true
      kubelet_extra_args   = "--node-labels=kubernetes.io/lifecycle=spot"
      suspended_processes  = ["AZRebalance"]
    }
  ]
}
