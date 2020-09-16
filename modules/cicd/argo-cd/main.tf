resource kubernetes_namespace this {
  depends_on = [
    var.module_depends_on
  ]
  metadata {
    name = var.namespace
  }
}

resource helm_release this {
  depends_on = [
    kubernetes_namespace.this
  ]

  name          = local.name
  repository    = local.repository
  chart         = local.chart
  version       = var.chart_version
  namespace     = kubernetes_namespace.this.metadata[0].name
  recreate_pods = true
  timeout       = 1200

  dynamic set {
    for_each = local.conf
    content {
      name  = set.key
      value = set.value
    }
  }
}

resource local_file this {
  depends_on = [
    helm_release.this
  ]
  content  = yamlencode(local.application)
  filename = "${path.root}/apps/${local.name}.yaml"
}

locals {
  repository = "https://argoproj.github.io/argo-helm"
  name       = "argocd"
  chart      = "argo-cd"
  conf = {
    "installCRDs" = false

    # Application which point to current working SAK repository
    "server.additionalApplications[0].name"                          = "swiss-army-kube"
    "server.additionalApplications[0].namespace"                     = kubernetes_namespace.this.metadata[0].name
    "server.additionalApplications[0].project"                       = "default"
    "server.additionalApplications[0].source.repoURL"                = "https://github.com/${var.owner}/${var.repository}"
    "server.additionalApplications[0].source.targetRevision"         = var.branch
    "server.additionalApplications[0].source.path"                   = "example/apps"
    "server.additionalApplications[0].destination.server"            = "https://kubernetes.default.svc"
    "server.additionalApplications[0].destination.namespace"         = kubernetes_namespace.this.metadata[0].name
    "server.additionalApplications[0].syncPolicy.automated.prune"    = "true"
    "server.additionalApplications[0].syncPolicy.automated.selfHeal" = "true"
  }
  # conf_defaults = merge({
  #   "installCRDs"            = false
  #   "server.ingress.enabled" = true,
  #   "server.config.url"      = "https://argo-cd.${var.domains[0]}",
  #   },
  #   { for i, domain in tolist(var.domains) : "server.ingress.tls[${i}].hosts[0]" => "argo-cd.${domain}" },
  #   { for i, domain in tolist(var.domains) : "server.ingress.hosts[${i}]" => "argo-cd.${domain}" },
  #   { for i, domain in tolist(var.domains) : "server.ingress.tls[${i}].secretName" => "argo-cd-${domain}-tls" }
  # )
  application = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = local.name
      "namespace" = kubernetes_namespace.this.metadata[0].name
    }
    "spec" = {
      "destination" = {
        "namespace" = kubernetes_namespace.this.metadata[0].name
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = local.repository
        "targetRevision" = var.chart_version
        "chart"          = local.chart
        "helm" = {
          "parameters" = [
            {
              "name"  = "installCRDs"
              "value" = "false"
            },
            {
              "name"  = "configs.secret.argocdServerAdminPassword"
              "value" = bcrypt("password", 10)
            }
          ]
        }
        "syncPolicy" = {
          "automated" = {
            "prune"    = "true"
            "selfHeal" = "true"
          }
        }
      }
    }
  }
}
