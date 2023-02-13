locals {
  ### VPC locals

  zones   = coalescelist(var.availability_zones, data.aws_availability_zones.available.names)
  cidr    = var.cidr != null ? var.cidr : "10.${var.network}.0.0/16"
  private = var.cidr != null ? [for i, z in local.zones : cidrsubnet(local.cidr, var.network_delimiter, i)] : [for i, _ in local.zones : "10.${var.network}.20${i}.0/24"]
  public  = var.cidr != null ? [for i, z in local.zones : cidrsubnet(local.cidr, var.network_delimiter, pow(2, var.network_delimiter) - i)] : [for i, _ in local.zones : "10.${var.network}.${i}.0/24"]

  #EKS module local
  environment  = var.environment
  project      = var.project
  cluster_name = var.cluster_name
  domain       = ["${local.cluster_name}.${var.domain_name}"]
  subnets      = module.vpc.private_subnets

  registry = "https://registry.${local.domain[0]}"

}
