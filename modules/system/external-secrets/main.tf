data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "local_file" "values" {
  content = templatefile("${path.module}/helm-app-template/${local.app_name}.yaml",
    {
      chart_values               = local.chart_values
      chart_repo                 = var.chart_repository
      chart_version              = var.chart_version
      module_name                = local.module_name
      app_name                   = local.app_name
      app_namespace              = var.namespace
      argo_namespace             = var.argocd.namespace
      chart_parameters           = var.chart_parameters
      chart_parameters_as_string = var.chart_parameters_as_string
  })
  file_permission      = "0644"
  directory_permission = "0755"
  filename             = "${path.root}/${var.argocd.path}/${local.app_name}.yaml"
}
