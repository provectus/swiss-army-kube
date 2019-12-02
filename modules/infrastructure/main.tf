# Declare the data source
data "aws_availability_zones" "available" {}

data "template_file" "private" {
  count    = length(data.aws_availability_zones.available.names)
  template = cidrsubnet(local.network, 8, count.index)
}

data "template_file" "public" {
  count    = length(data.aws_availability_zones.available.names)
  template = cidrsubnet(local.network, 8, count.index + 100)
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

locals {
  network = cidrsubnet("10.0.0.0/8", 8, var.network)
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = ">= v2.21.0"

  name = "${var.cluster_name}"

  cidr = local.network

  azs             = data.aws_availability_zones.available.names
  private_subnets = data.template_file.private.*.rendered
  public_subnets  = data.template_file.public.*.rendered

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    KubernetesCluster        = "${var.cluster_name}"
    "kubernetes.io/role/elb" = ""
  }
  private_subnet_tags = {
    KubernetesCluster        = "${var.cluster_name}"
    "kubernetes.io/role/internal-elb" = ""
  }

  tags = {
    Environment = var.cluster_name
  }
}

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  version = ">= v7.0.0"  
  cluster_name = "${var.cluster_name}"
  subnets      = module.vpc.private_subnets
  vpc_id       = module.vpc.vpc_id

  map_users       = null_resource.map_users.*.triggers

  tags = {
    Environment = var.cluster_name
  }

  workers_additional_policies = [
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
  ]
  worker_groups = [
    {
      spot_price    = var.spot_price
      instance_type = var.eks_instance_type
      asg_max_size  = var.cluster_size
    },
  ]
}
