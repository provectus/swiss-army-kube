# Declare the data source
data "aws_availability_zones" "available" {}

data "aws_region" "current" {}

# Enabling IAM Roles for Service Accounts 
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.cluster.arn]
      type        = "Federated"
    }
  }
}

# EKS - aws kubernetes cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = ">= v7.0.0"  
  cluster_version = var.cluster_version
  cluster_name    = var.cluster_name
  subnets         = var.private_subnets
  vpc_id          = var.vpc_id 

  map_users       = null_resource.map_users.*.triggers

  tags = {
    Environment   = var.cluster_name
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
      asg_desired_capacity = var.on_demand_desired_capacity
      asg_min_size         = "2"
      autoscaling_enabled  = true
      kubelet_extra_args   = "--node-labels=kubernetes.io/lifecycle=normal"
      suspended_processes  = ["AZRebalance"]
    },
    {
      name                 = "spot-1"
      spot_price           = var.spot_price
      instance_type        = var.spot_instance_type
      asg_max_size         = var.spot_max_cluster_size
      asg_desired_capacity = var.spot_desired_capacity
      asg_min_size         = "1"
      autoscaling_enabled  = true
      kubelet_extra_args   = "--node-labels=kubernetes.io/lifecycle=spot"
      suspended_processes  = ["AZRebalance"]
    }
  ]
}
