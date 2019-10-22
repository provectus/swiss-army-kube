data "aws_availability_zones" "available" {}

locals {
  zones = coalescelist(var.cluster_zones, data.aws_availability_zones.available.names)
}

data "template_file" "private" {
  count    = length(local.zones)
  template = "10.${var.network}.${count.index}.0/24"
}

data "template_file" "public" {
  count    = length(local.zones)
  template = "10.${var.network}.10${count.index}.0/24"
}

module "vpc" {
  azs             = local.zones
  cidr = "10.${var.network}.0.0/16"
  enable_nat_gateway = true
  name = "${var.cluster_name}-cluster"
  private_subnets = data.template_file.private.*.rendered
  public_subnets  = data.template_file.public.*.rendered
  single_nat_gateway = true
  source = "terraform-aws-modules/vpc/aws"

  public_subnet_tags = {
    KubernetesCluster        = "${var.cluster_name}-cluster"
    "kubernetes.io/role/elb" = ""
  }

  tags = {
    Environment = var.cluster_name
  }
}

resource "null_resource" "map_users" {
  count = length(var.admin_arns)

  triggers = {
    group    = "system:masters"
    user_arn = element(var.admin_arns, count.index)
    username = "{{UserID}}"
  }
}

module "eks" {
  cluster_name = "${var.cluster_name}-cluster"
  map_users = null_resource.map_users.*.triggers
  source       = "terraform-aws-modules/eks/aws"
  subnets      = module.vpc.private_subnets
  vpc_id       = module.vpc.vpc_id
  workers_additional_policies = [
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
  ]
  worker_groups = [
    for subnet in module.vpc.private_subnets :
    {
      asg_min_size        = 1
      asg_max_size        = var.cluster_size
      autoscaling_enabled = true
      instance_type       = "t3.medium"
      spot_price          = var.spot_price
      subnets             = list(subnet)
    }
  ]
}
