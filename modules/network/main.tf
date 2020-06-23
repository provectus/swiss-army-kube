locals {
  zones   = coalescelist(var.availability_zones, data.aws_availability_zones.available.names)
  cidr    = var.cidr != null ? var.cidr : "10.${var.network}.0.0/16"
  private = var.cidr != null ? [for i, z in local.zones : cidrsubnet(local.cidr, var.network_delimiter, i)] : data.template_file.private.*.rendered
  public  = var.cidr != null ? [for i, z in local.zones : cidrsubnet(local.cidr, var.network_delimiter, pow(2, var.network_delimiter) - i)] : data.template_file.public.*.rendered
}

data "aws_availability_zones" "available" {}

data "template_file" "public" {
  count    = length(local.zones)
  template = "10.${var.network}.${count.index}.0/24"
}

data "template_file" "private" {
  count    = length(local.zones)
  template = "10.${var.network}.20${count.index}.0/24"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v2.33.0"

  name = "${var.environment}-${var.cluster_name}"

  cidr = local.cidr

  azs             = local.zones
  private_subnets = local.private
  public_subnets  = local.public

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    Name                                        = "${var.environment}-${var.cluster_name}-public"
    KubernetesCluster                           = "${var.cluster_name}"
    Environment                                 = var.environment
    Project                                     = var.project
    "kubernetes.io/role/elb"                    = ""
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    Name                                        = "${var.environment}-${var.cluster_name}-private"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  tags = {
    Name        = "${var.environment}-${var.cluster_name}"
    Environment = var.environment
    Project     = var.project
    Terraform   = "true"
  }
}
