provider "aws" {
  region = "${var.aws_region}"
}

terraform {
  backend "s3" {
    bucket = "sak-dev-tf-states"
    key    = "infrastructure/dev/states"
    region = "us-west-2"
    dynamodb_table = "terraform-lock"
  }
}

data "aws_availability_zones" "available" {}

data "template_file" "private" {
  count = "${length(data.aws_availability_zones.available.names)}"
  template = "10.0.${count.index}.0/24"
}

data "template_file" "public" {
  count = "${length(data.aws_availability_zones.available.names)}"
  template = "10.0.10${count.index}.0/24"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev"

  cidr = "10.0.0.0/16"

  azs             = "${data.aws_availability_zones.available.names}"
  private_subnets = "${data.template_file.private.*.rendered}"
  public_subnets  = "${data.template_file.public.*.rendered}"

  assign_generated_ipv6_cidr_block = true

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Owner       = "sak"
    Environment = "dev"
  }

  public_subnet_tags = {
    
  }

  vpc_tags = {
    Name = "dev"
  }
}

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = "${var.cluster_name}"
  subnets      = "${module.vpc.private_subnets}"
  vpc_id       = "${module.vpc.vpc_id}"

  worker_groups = [
    {
      instance_type = "m5.large"
      asg_max_size  = "${var.cluster_size}"
    }
  ]

  tags = {
    environment = "dev"
  }
}
