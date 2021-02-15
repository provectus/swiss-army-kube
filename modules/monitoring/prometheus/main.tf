data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_region" "current" {}

resource "random_password" "grafana_password" {
  depends_on = [
    var.module_depends_on
  ]
  length           = 16
  special          = true
  override_special = "!#%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "grafana_password" {
  name  = "/${var.cluster_name}/grafana/password"
  type  = "SecureString"
  value = local.password
}

resource "kubernetes_namespace" "this" {
  depends_on = [
    var.module_depends_on
  ]
  name          = "prometheus-operator"
  repository    = "https://charts.helm.sh/stable"
  chart         = "prometheus-operator"
  version       = "9.3.1"
  namespace     = kubernetes_namespace.monitoring.metadata[0].name
  recreate_pods = true
  timeout       = 1200


  values = [templatefile("${path.module}/values/prometheus.yaml",
    {
      alertmanager_enabled         = true
      alertmanager_ingress_enabled = false
      alertmanager_host            = "alertmanager.${var.domains[0]}"
      certmanager_issuer           = "letsencrypt-prod"
      grafana_enabled              = true
      grafana_version              = "7.1.1"
      grafana_pvc_enabled          = true
      grafana_ingress_enabled      = true
      grafana_admin_password       = random_password.grafana_password.result
      grafana_url                  = "grafana.${var.domains[0]}"
      grafana_google_auth          = var.grafana_google_auth
      grafana_allowed_domains      = var.grafana_allowed_domains
      prometheus_enabled           = true
      prometheus_ingress_enabled   = false
      prometheus_url               = "prometheus.${var.domains[0]}"
    })
  ]
  count = var.namespace == "" ? 1 - local.argocd_enabled : 0
  metadata {
    name = var.namespace_name
  }
}

resource "kubernetes_secret" "grafana_auth" {
  depends_on = [
    var.module_depends_on
  ]

  count = var.grafana_google_auth == true ? 1 - local.argocd_enabled : 0

  metadata {
    name      = "grafana-auth"
    namespace = local.namespace
  }

  data = {
    GF_AUTH_GOOGLE_CLIENT_ID     = var.grafana_client_id
    GF_AUTH_GOOGLE_CLIENT_SECRET = var.grafana_client_secret
  }
}

resource "aws_kms_ciphertext" "grafana_client_secret" {
  count     = var.grafana_google_auth == true && local.argocd_enabled > 0 ? 1 : 0
  key_id    = var.argocd.kms_key_id
  plaintext = base64encode(var.grafana_client_secret)
}

resource "aws_kms_ciphertext" "grafana_password" {
  count     = local.argocd_enabled
  key_id    = var.argocd.kms_key_id
  plaintext = local.password
}

resource "local_file" "namespace" {
  count = local.argocd_enabled
  depends_on = [
    var.module_depends_on
  ]
  content = yamlencode({
    "apiVersion" = "v1"
    "kind"       = "Namespace"
    "metadata" = {
      "name" = local.namespace
    }
  })
  filename = "${path.root}/${var.argocd.path}/ns-${local.namespace}.yaml"
}

resource "local_file" "grafana_auth" {
  count = var.grafana_google_auth == true ? local.argocd_enabled : 0
  depends_on = [
    var.module_depends_on
  ]
  content = yamlencode({
    "apiVersion" = "v1"
    "kind"       = "Secret"
    "metadata" = {
      "name"      = "grafana-auth"
      "namespace" = local.namespace
    }
    "data" = {
      "GF_AUTH_GOOGLE_CLIENT_ID"     = var.grafana_client_id
      "GF_AUTH_GOOGLE_CLIENT_SECRET" = "KMS_ENC:${aws_kms_ciphertext.grafana_client_secret[0].ciphertext_blob}:"
    }
  })
  filename = "${path.root}/${var.argocd.path}/secret-grafana-auth.yaml"
}

locals {
  argocd_enabled = length(var.argocd) > 0 ? 1 : 0
  namespace      = coalescelist(var.namespace == "" && local.argocd_enabled > 0 ? [{ "metadata" = [{ "name" = var.namespace_name }] }] : kubernetes_namespace.this, [{ "metadata" = [{ "name" = var.namespace }] }])[0].metadata[0].name
}

resource "helm_release" "this" {
  count = 1 - local.argocd_enabled

  depends_on = [
    var.module_depends_on
  ]

  name          = local.name
  repository    = local.repository
  chart         = local.chart
  version       = var.chart_version
  namespace     = local.namespace
  recreate_pods = true
  timeout       = 1200

  dynamic "set" {
    for_each = merge(local.conf)

    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "local_file" "this" {
  count = local.argocd_enabled
  depends_on = [
    var.module_depends_on
  ]
  content  = yamlencode(local.application)
  filename = "${path.root}/${var.argocd.path}/${local.name}.yaml"
}


locals {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  conf       = merge(local.conf_defaults, var.conf)
  password   = var.grafana_password == "" ? random_password.grafana_password.result : var.grafana_password
  conf_defaults = {
    "alertmanager.enabled"       = true
    "grafana.enabled"            = true
    "grafana.pvc.enabled"        = true
    "grafana.ingress.enabled"    = true
    "grafana.ingress.hosts[0]"   = "grafana.${var.domains[0]}"
    "grafana.adminPassword"      = local.argocd_enabled > 0 ? "KMS_ENC:${aws_kms_ciphertext.grafana_password[0].ciphertext_blob}:" : local.password
    "grafana.google.auth"        = var.grafana_google_auth
    "grafana.allowed.domains"    = var.grafana_allowed_domains
    "prometheus.enabled"         = true
    "prometheus.ingress.enabled" = false
    "namespace"                  = local.namespace
    "rbac.create"                = true,
    "resources.limits.cpu"       = "100m",
    "resources.limits.memory"    = "300Mi",
    "resources.requests.cpu"     = "100m",
    "resources.requests.memory"  = "300Mi"
  }
  application = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = local.name
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = local.namespace
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = local.repository
        "targetRevision" = var.chart_version
        "chart"          = local.chart
        "helm" = {
          "parameters" = values({
            for key, value in local.conf :
            key => {
              "name"  = key
              "value" = tostring(value)
            }
          })
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
