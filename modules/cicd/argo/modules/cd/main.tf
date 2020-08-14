resource "helm_release" "argo-cd" {
  depends_on = [
    var.module_depends_on
  ]

  name          = "argocd"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-cd"
  version       = "2.3.5"
  namespace     = var.namespace
  recreate_pods = true
  timeout       = 1200
  values = [
    file("${path.module}/values.yml")
  ]
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
    "installCRDs"            = false
    "server.ingress.enabled" = true,
    "server.config.url"      = "https://argo-cd.${var.domains[0]}",
    },
    { for i, domain in tolist(var.domains) : "server.ingress.tls[${i}].hosts[0]" => "argo-cd.${domain}" },
    { for i, domain in tolist(var.domains) : "server.ingress.hosts[${i}]" => "argo-cd.${domain}" },
    { for i, domain in tolist(var.domains) : "server.ingress.tls[${i}].secretName" => "argo-cd-${domain}-tls" }
  )
}
