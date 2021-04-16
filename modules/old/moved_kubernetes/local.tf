locals {
  tags = var.tags != null ? var.tags : {
    Environment = var.environment
    Project     = var.project
  }

  workers_additional_policies = flatten(
    [
      ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"], var.workers_additional_policies
    ]
  )
}