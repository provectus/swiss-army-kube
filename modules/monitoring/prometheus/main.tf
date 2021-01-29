# Create namespace monitoring
resource "kubernetes_namespace" "monitoring" {
  depends_on = [
    var.module_depends_on
  ]
  metadata {
    name = "monitoring"
  }
}

resource "random_password" "grafana_password" {
  length           = 16
  special          = true
  override_special = "!#%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "grafana_password" {
  name  = "/grafana/${var.cluster_name}/admin"
  type  = "SecureString"
  value = random_password.grafana_password.result
}

resource "helm_release" "monitoring" {
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
}

resource "kubernetes_secret" "grafana_auth" {
  depends_on = [
    var.module_depends_on
  ]

  count = var.grafana_google_auth == true ? 1 : 0

  metadata {
    name      = "grafana-auth"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    GF_AUTH_GOOGLE_CLIENT_ID     = var.grafana_client_id
    GF_AUTH_GOOGLE_CLIENT_SECRET = var.grafana_client_secret
  }
}