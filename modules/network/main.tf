
data "template_file" "public" {
  count    = "${length(var.availability_zones)}"
  template = "10.${var.network}.${count.index}.0/24"
}

data "template_file" "private" {
  count    = "${length(var.availability_zones)}"
  template = "10.${var.network}.20${count.index}.0/24"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v2.21.0"

  name = "${var.environment}-${var.cluster_name}"

  cidr = "10.${var.network}.0.0/16"

  azs             = "${var.availability_zones}"
  private_subnets = "${data.template_file.private.*.rendered}"
  public_subnets  = "${data.template_file.public.*.rendered}"

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
  }

  private_subnet_tags = {
    Name = "${var.environment}-${var.cluster_name}-private"
  }

  tags = {
    Name        = "${var.environment}-${var.cluster_name}"
    Environment = var.environment
    Project     = var.project
    Terraform   = "true"
  }
}
