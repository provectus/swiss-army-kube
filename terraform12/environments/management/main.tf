terraform {
  backend "s3" {
    bucket         = "opsdata"
    key            = "terraform/states/management/main.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "TerraformStateLocks"
  }
  required_version = ">= 0.12.0"
}

variable "environment" {
  type        = "string"
  description = "Environment"
  default     = "management"
}

provider "aws" {
  region  = "us-east-2"
  version = "2.20.0"
}


data "template_file" "public" {
  count    = "2"
  template = "10.20.${count.index}.0/24"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.9.0"

  name = "${var.environment}"

  cidr = "10.20.0.0/16"

  azs             = ["us-east-2a", "us-east-2b"]

  public_subnets  = "${data.template_file.public.*.rendered}"

  assign_generated_ipv6_cidr_block = false

  enable_nat_gateway = false
  single_nat_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    Name = "${var.environment}-public"
  }

  tags = {
    Name = "${var.environment}"
    Environment = "${var.environment}"
    Terraform = "true"
  }
}

data "aws_caller_identity" "current" {}


### Staging environment state
data "terraform_remote_state" "staging" {
  backend = "s3"
  config = {
    bucket = "opsdata"
    key    = "terraform/states/staging/airflow.tfstate"
    region = "us-east-2"
  }
}

resource "aws_vpc_peering_connection" "mgmt-staging" {
  peer_owner_id = "${data.aws_caller_identity.current.account_id}"
  peer_vpc_id   = data.terraform_remote_state.staging.outputs.vpc_id
  vpc_id        = module.vpc.vpc_id
  auto_accept   = true

  tags = {
    Name = "VPC Peering between Management and Staging"
  }

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}


### peering connection between Management vpc and Current Default VPC

resource "aws_vpc_peering_connection" "mgmt-default-vpc" {
  peer_owner_id = "${data.aws_caller_identity.current.account_id}"
  peer_vpc_id   = "vpc-20bff249"
  vpc_id        = module.vpc.vpc_id
  auto_accept   = true

  tags = {
    Name = "VPC Peering between Management and Current Default VPC"
  }

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}
