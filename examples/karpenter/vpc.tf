module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v2.64.0"

  name = "${local.environment}-${local.cluster_name}"

  cidr = local.cidr

  azs             = local.zones
  private_subnets = local.private
  public_subnets  = local.public

  enable_nat_gateway = true
  single_nat_gateway = var.single_nat

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    Name                                          = "${local.environment}-${local.cluster_name}-public"
    KubernetesCluster                             = local.cluster_name
    Environment                                   = local.environment
    Project                                       = local.project
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    Name                                          = "${local.environment}-${local.cluster_name}-private"
    "kubernetes.io/role/elb-internal"             = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = "true"
  }

  tags = {
    Name        = "${local.environment}-${local.cluster_name}"
    Environment = local.environment
    Project     = local.project
    Terraform   = "true"
  }
}