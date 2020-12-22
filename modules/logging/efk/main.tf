# Create namespace efk
resource "kubernetes_namespace" "efk" {
  depends_on = [
    var.module_depends_on
  ]
  metadata {
    name = "efk"
  }
}

resource "helm_release" "elastic-stack" {
  depends_on = [
    var.module_depends_on
  ]

  name       = "elastic"
  repository = "https://charts.helm.sh/stable"
  chart      = "elastic-stack"
  version    = "2.0.1"
  namespace  = "efk"

  values = [
    file("${path.module}/values/elastic-stack.yaml"),
  ]

  set {
    name  = "kibana.ingress.hosts[0]"
    value = "kibana.${var.domains[0]}"
  }

  set {
    name  = "kibana.ingress.tls[0].hosts[0]"
    value = "kibana.${var.domains[0]}"
  }

  set {
    name  = "kibana.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-url"
    value = var.efk_oauth2_domain == "" ? "" : "https://${var.efk_oauth2_domain}.${var.domains[0]}/oauth2/auth"
  }

  set {
    name  = "kibana.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-signin"
    value = var.efk_oauth2_domain == "" ? "" : "https://${var.efk_oauth2_domain}.${var.domains[0]}/oauth2/sign_in?rd=$scheme://$host$request_uri"
  }

  set {
    name  = "logstash.enabled"
    value = var.logstash
  }

  set {
    name  = "filebeat.enabled"
    value = var.filebeat
  }

  set {
    name  = "elasticsearch-curator.enabled"
    value = var.elasticsearch-curator
  }

  set {
    name  = "elasticsearch-curator.cronjob.failedJobsHistoryLimit"
    value = var.failed_limit
  }

  set {
    name  = "elasticsearch-curator.cronjob.successfulJobsHistoryLimit"
    value = var.success_limit
  }

  set {
    name  = "elasticsearch.data.persistence.size"
    value = var.elasticDataSize
  }
}
