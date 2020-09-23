resource kubernetes_namespace this {
  depends_on = [
    var.module_depends_on
  ]
  metadata {
    name = "argocd"
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

resource random_password this {
  length  = 20
  special = true
}

resource aws_ssm_parameter this {
  name        = "/${var.cluster_name}/argocd/password"
  type        = "SecureString"
  value       = random_password.this.result
  description = "A password for accessing ArgoCD installation in ${var.cluster_name} EKS cluster"
}

locals {
  repository = "https://argoproj.github.io/argo-helm"
  name       = "argocd"
  chart      = "argo-cd"
  conf = {
    "installCRDs" = false

    "server.additionalApplications[0].name"                          = "swiss-army-kube"
    "server.additionalApplications[0].namespace"                     = kubernetes_namespace.this.metadata[0].name
    "server.additionalApplications[0].project"                       = "default"
    "server.additionalApplications[0].source.repoURL"                = "https://${var.vcs}/${var.owner}/${var.repository}"
    "server.additionalApplications[0].source.targetRevision"         = var.branch
    "server.additionalApplications[0].source.path"                   = "apps"
    "server.additionalApplications[0].destination.server"            = "https://kubernetes.default.svc"
    "server.additionalApplications[0].destination.namespace"         = kubernetes_namespace.this.metadata[0].name
    "server.additionalApplications[0].syncPolicy.automated.prune"    = "true"
    "server.additionalApplications[0].syncPolicy.automated.selfHeal" = "true"
  }
  values = concat([
    {
      "name"  = "global.image.repository"
      "value" = "provectuslabs/argocd"
    },
    {
      "name"  = "global.image.tag"
      "value" = "v1.7.4"
    },
    {
      "name"  = "installCRDs"
      "value" = "false"
    },
    {
      "name"  = "configs.secret.argocdServerAdminPassword"
      "value" = bcrypt(random_password.this.result, 10)
    },
    {
      "name"  = "server.ingress.enabled"
      "value" = "true"
    },
    {
      "name"  = "server.config.url"
      "value" = "https://argo-cd.${var.domains[0]}"
    }
    ],
    values({
      for i, domain in tolist(var.domains) :
      "key" => {
        "name"  = "server.ingress.tls[${i}].hosts[0]"
        "value" = "argo-cd.${domain}"
      }
    }),
    values({
      for i, domain in tolist(var.domains) :
      "key" => {
        "name"  = "server.ingress.hosts[${i}]"
        "value" = "argo-cd.${domain}"
      }
    }),
    values({
      for i, domain in tolist(var.domains) :
      "key" => {
        "name"  = "server.ingress.tls[${i}].secretName"
        "value" = "argo-cd-${domain}-tls"
      }
    })
  )
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
          "parameters" = local.values
        }
      }
      "syncPolicy" = {
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
      }
    }
  }
}
