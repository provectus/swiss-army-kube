data "aws_region" "current" {}

resource "kubernetes_namespace" "this" {
  count = var.namespace_name == "kube-system" ? 0 : 1
  metadata {
    name = var.namespace_name
  }
}

resource "kubernetes_limit_range" "this" {
  count = var.namespace_name == "kube-system" ? 0 : 1
  metadata {
    name      = "default-limits"
    namespace = var.namespace_name
  }
  spec {
    limit {
      type = "Container"
      max = {
        cpu    = "1"
        memory = "2G"
      }
      default = {
        cpu    = "500m"
        memory = "1G"
      }
      default_request = {
        cpu    = "50m"
        memory = "128M"
      }
    }
  }
}

resource "random_password" "password" {
  length = 8
}

locals {
  monitoring_defaults = {
    "grafana.adminPassword"   = random_password.password.result,
    "grafana.ingress.enabled" = false,
    "rbac.create"             = true,
    "rbac.pspEnabled"         = true,

  }
}

resource "helm_release" "monitoring" {
  count      = var.monitoring.enabled ? 1 : 0
  name       = "prometheus-operator"
  repository = "stable"
  chart      = "prometheus-operator"
  version    = "6.20.3"
  namespace  = var.namespace_name

  dynamic set {
    for_each = merge(local.monitoring_defaults, var.monitoring.parameters)

    content {
      name  = set.key
      value = set.value
    }
  }
}

output "grafana_admin_password" {
  value = random_password.password.result
}
