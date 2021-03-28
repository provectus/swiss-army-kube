output "state" {
  value = {
    repository = var.sync_repo_url
    branch     = var.sync_branch
    namespace  = kubernetes_namespace.this.metadata[0].name
    path       = var.sync_apps_dir
    full_path  = "${var.sync_path_prefix}${var.sync_apps_dir}"
  }
}
