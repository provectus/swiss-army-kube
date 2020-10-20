output state {
  value = {
    repository = local.repoURL
    branch     = var.branch
    namespace  = local.namespace
    path       = var.apps_dir
    full_path  = "${var.path_prefix}${var.apps_dir}"
  }
}
