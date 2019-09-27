data "aws_availability_zones" "available" {
}

data "template_file" "private" {
  count    = length(data.aws_availability_zones.available.names)
  template = "10.${var.network}.${count.index}.0/24"
}

data "template_file" "public" {
  count    = length(data.aws_availability_zones.available.names)
  template = "10.${var.network}.10${count.index}.0/24"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.cluster_name}-cluster"

  cidr = "10.${var.network}.0.0/16"

  azs             = data.aws_availability_zones.available.names
  private_subnets = data.template_file.private.*.rendered
  public_subnets  = data.template_file.public.*.rendered

  assign_generated_ipv6_cidr_block = true

  enable_nat_gateway = true
  single_nat_gateway = true

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
    user_arn = element(var.admin_arns, count.index)
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
  map_users_count = length(var.admin_arns)
  workers_additional_policies = [
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
  ]
  workers_additional_policies_count = 2
  worker_groups = [
    {
      spot_price    = var.spot_price
      instance_type = "m5.large"
      asg_max_size  = var.cluster_size
    },
  ]
}
