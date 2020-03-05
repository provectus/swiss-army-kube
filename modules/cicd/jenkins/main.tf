#Global helm chart repo
data "helm_repository" "incubator" {
  name = "incubator"
  url  = "https://kubernetes-charts-incubator.storage.googleapis.com"
}

resource "helm_release" "jenkins" {
  depends_on = [
    var.module_depends_on
  ]   
  
  name          = "jenkins"
  repository    = "stable"
  chart         = "jenkins"
  version       = "1.9.16"
  namespace     = "jenkins"
  recreate_pods = true

  set {
    name  = "master.adminPassword"
    value = var.jenkins_password
  }

  set {
    name  = "master.ingress.enabled"
    value = "true"
  }


//TODO: fix it for multi domains
  set {
      name  = "master.ingress.hostName"
      value = "jenkins.${var.domains[0]}"
  }

  dynamic "set" {
    for_each = var.domains
    content {  
      name  = "master.ingress.tls[${set.key}].secretName"
      value = "jenkins-${set.key}-tls"
    }
  }
  dynamic "set" {
    for_each = var.domains
    content {  
      name  = "master.ingress.tls[${set.key}].hosts[0]"
      value = "jenkins.${set.value}"
    }
  }

  values = [
    file("${path.module}/values.yml")
  ]
}
