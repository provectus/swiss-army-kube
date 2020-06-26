# Create namespace efk
resource "kubernetes_namespace" "efk" {
  depends_on = [
    var.module_depends_on
  ]
  metadata {
    name = "efk"
  }
}

resource "helm_release" "elasticsearch" {
  depends_on = [
    var.module_depends_on
  ]

  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
//  version    = "7.8.0"
  namespace  = "efk"

  values = [
    file("${path.module}/values/elasticsearch.yaml"),
  ]

  set {
    name  = "volumeClaimTemplate.resources.requests.storage"
    value = var.elasticDataSize
  }
}

resource "helm_release" "kibana" {
  depends_on = [
    var.module_depends_on
  ]

  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
//  version    = "7.8.0"
  namespace  = "efk"

  values = [
    file("${path.module}/values/kibana.yaml"),
  ]

  set {
    name  = "ingress.hosts[0]"
    value = "kibana.${var.domains[0]}"
  }

  set {
    name  = "ingress.tls[0].hosts[0]"
    value = "kibana.${var.domains[0]}"
  }
}

resource "helm_release" "filebeat" {
  depends_on = [
    var.module_depends_on
  ]

  name       = "filebeat"
  repository = "https://helm.elastic.co"
  chart      = "filebeat"
//  version    = "7.8.0"
  namespace  = "efk"

  values = [
    file("${path.module}/values/filebeat.yaml"),
  ]
}

resource "helm_release" "elasticsearch-curator" {
  depends_on = [
    var.module_depends_on
  ]

  name       = "elasticsearch-curator"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "elasticsearch-curator"
  version    = "2.1.5"
  namespace  = "efk"

  values = [
    file("${path.module}/values/curator.yaml"),
  ]

  set {
    name  = "cronjob.failedJobsHistoryLimit"
    value = var.failed_limit
  }

  set {
    name  = "cronjob.successfulJobsHistoryLimit"
    value = var.success_limit
  }
}



