output state {
  value = {
    repository = local.repoURL
    branch     = var.branch
    namespace  = kubernetes_namespace.this.metadata[0].name
    path       = "${var.path_prefix}/apps"
  }
}
