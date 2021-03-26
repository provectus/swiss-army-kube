locals {
  vpc_name = var.vpc_name != null ? var.vpc_name : "${var.environment}-${var.cluster_name}"
}