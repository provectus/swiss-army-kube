data "aws_availability_zones" "available" {
}

data "template_file" "private" {
  count    = length(data.aws_availability_zones.available.names)
  template = cidrsubnet(local.network, 8, count.index)
}

data "template_file" "public" {
  count    = length(data.aws_availability_zones.available.names)
  template = cidrsubnet(local.network, 8, count.index + 100)
}

locals {
  network = cidrsubnet("10.0.0.0/8", 8, var.network)
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.cluster_name}-cluster"

  cidr = local.network

  azs             = data.aws_availability_zones.available.names
  private_subnets = data.template_file.private.*.rendered
  public_subnets  = data.template_file.public.*.rendered

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true

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
    user_arn = var.admin_arns[count.index]
    username = "{{UserID}}"
    group    = "system:masters"
  }
}

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = "${var.cluster_name}-cluster"
  subnets      = module.vpc.private_subnets
  vpc_id       = module.vpc.vpc_id

  map_users       = null_resource.map_users.*.triggers
  workers_additional_policies = [
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
  ]
  worker_groups = [
    {
      spot_price    = var.spot_price
      instance_type = var.eks_instance_size
      asg_max_size  = var.cluster_size
    },
  ]
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_id" {
  value = module.eks.cluster_id
}
