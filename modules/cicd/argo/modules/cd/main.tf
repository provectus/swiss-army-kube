data "helm_repository" "argo" {
  name = "argo"
  url  = "https://argoproj.github.io/argo-helm"
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argo-cd" {
  depends_on = [
    var.module_depends_on
  ]

  name          = "argo-cd"
  repository    = "argo"
  chart         = "argo-cd"
  version       = "2.2.8"
  namespace     = kubernetes_namespace.this.metadata[0].name
  recreate_pods = true

  dynamic set {
    for_each = merge(local.cd_conf_defaults, var.cd_conf)

    content {
      name  = set.key
      value = set.value
    }
  }
}

locals {
  cd_conf_defaults = merge({
    "server.ingress.enabled" = true,
    "server.config.url"      = "https://argo-cd.${var.domains[0]}",
    },
    { for i, domain in tolist(var.domains) : "server.ingress.tls[${i}].hosts[0]" => "argo-cd.${domain}" },
    { for i, domain in tolist(var.domains) : "server.ingress.hosts[${i}]" => "argo-cd.${domain}" },
    { for i, domain in tolist(var.domains) : "server.ingress.tls[${i}].secretName" => "argo-cd-${domain}-tls" }
  )
}
