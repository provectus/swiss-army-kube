locals {
  module_name         = basename(abspath(path.module))
  app_name            = "external-secrets"
  cluster_name        = var.cluster_output.cluster_id
  aws_region          = var.aws_region == "" ? data.aws_region.current.name : var.aws_region
  aws_assume_role_arn = length(module.iam_assumable_role) > 0 && var.aws_assume_role_arn == "" ? module.iam_assumable_role[0].arn : var.aws_assume_role_arn
  template_helm_values = templatefile("${path.module}/values/values.yaml",
    {
      aws_assume_role_arn = local.aws_assume_role_arn
      poller_interval     = var.poller_interval
      aws_region          = local.aws_region
      app_name            = local.app_name
  })
  chart_values = var.chart_values == "" ? local.template_helm_values : var.chart_values
}
