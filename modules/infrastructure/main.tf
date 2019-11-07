data "aws_availability_zones" "available" {}

locals {
  zones            = coalescelist(var.cluster_zones, data.aws_availability_zones.available.names)
  private_net      = [for i, z in local.zones : cidrsubnet(var.network, var.network_delim, i)]
  public_net       = [for i, z in local.zones : cidrsubnet(var.network, var.network_delim, 255 - i)]
  additional_users = [for arn in var.admin_arns : zipmap(["userarn", "username", "groups"], [arn, "{{UserID}}", ["system:masters"]])]
}

module "vpc" {
  azs                = local.zones
  cidr               = var.network
  enable_nat_gateway = true
  name               = var.cluster_name
  private_subnets    = local.private_net
  public_subnets     = local.public_net
  single_nat_gateway = true
  source             = "terraform-aws-modules/vpc/aws"

  public_subnet_tags = {
    KubernetesCluster        = var.cluster_name
    "kubernetes.io/role/elb" = ""
  }

  tags = {
    Environment = var.cluster_name
  }
}

module "eks" {
  cluster_name = var.cluster_name
  map_users    = local.additional_users
  source       = "terraform-aws-modules/eks/aws"
  subnets      = module.vpc.private_subnets
  vpc_id       = module.vpc.vpc_id
  # future-request: switch to using AWS IRSA
  workers_additional_policies = [
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
  ]
  worker_groups = [
    for index, subnet in module.vpc.private_subnets :
    {
      asg_min_size        = index == 0 ? 1 : 0
      asg_max_size        = var.cluster_size
      autoscaling_enabled = true
      instance_type       = var.instance_type
      spot_price          = var.spot_price
      subnets             = list(subnet)
    }
  ]
}
