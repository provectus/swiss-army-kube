
terraform {
  backend "s3" {
    bucket         = "opsdata"
    key            = "terraform/states/production/airflow.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "TerraformStateLocks"
  }
  required_version = ">= 0.12.0"
}

variable "environment" {
  type        = "string"
  description = "Environment"
  default     = "production"
}

variable "cluster_name" {
  type        = "string"
  description = "Kubernetes cluster name"
  default     = "prod-cluster"
}

provider "aws" {
  region  = "us-east-2"
  version = "2.23.0"
}



variable "kuber_admins" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type        = list(map(string))

  default = [
    {
      user_arn = "arn:aws:iam::AWS_ACCOUNT_ID:user/sergey.fadeev"
      username = "sergey.fadeev"
      group    = "system:masters"
    },
  ]
}

### --------->>>>>>> module: network
module "network" {
  source = "../../modules/network"

  environment = var.environment

  availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]

  cluster_name = "${var.cluster_name}"

  ### vpc: 10.${var.network}.0.0/16
  network = "1"
}



data "aws_region" "current" {}

## --------->>>>>>> module: Kubernetes

module "kubernetes" {
  source = "../../modules/kubernetes"

  environment = var.environment

  cluster_name     = "${var.cluster_name}"
  max_cluster_size = "6"
  desired_capacity = "3"
  cluster_version  = "1.13"
  instance_type    = "m5.large"

  aws_region      = data.aws_region.current.name
  vpc_id          = module.network.vpc_id
  private_subnets = module.network.private_subnets

  admin_arns = var.kuber_admins

  domain             = "SET_YOUR_DOMAIN"
  cert_manager_email = "YOUR_EMAIL"
}

module "oauth2proxy" {
  source = "../../modules/oauth2proxy"

  domain = "SET_YOUR_DOMAIN"
}

module "airflow" {
  source       = "../../modules/airflow"

  environment   = var.environment
  cluster_name  = var.cluster_name
  vpc_id        = module.network.vpc_id

  ### DB airflow settings:
  db_backup_retention = "30"
  instance_class      = "db.m5.large"
  allocated_storage   = "300"
}
