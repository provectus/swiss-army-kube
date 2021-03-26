locals {
  module_name  = basename(abspath(path.module))
  app_name     = "external-secrets"
  cluster_name = var.cluster_name
  aws_region   = var.aws_region == "" ? data.aws_region.current.name : var.aws_region

  create_role               = var.chart_values != "" || var.aws_assume_role_arn != "" ? false : true
  create_full_access_policy = local.create_role && var.secret_manager_full_access ? true : false
  role_policy_arns          = local.create_full_access_policy ? [aws_iam_policy.this[0].arn] : []
  aws_assume_role_arn       = local.create_role ? module.iam_assumable_role[0].this_iam_role_arn : var.aws_assume_role_arn
  template_helm_values = templatefile("${path.module}/values/values.yaml",
    {
      aws_assume_role_arn = local.aws_assume_role_arn
      poller_interval     = var.poller_interval
      aws_region          = local.aws_region
      app_name            = local.app_name
  })
  chart_values = var.chart_values == "" ? local.template_helm_values : var.chart_values
}
