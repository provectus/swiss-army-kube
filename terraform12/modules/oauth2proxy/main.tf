### https://blog.donbowman.ca/2019/02/14/using-single-sign-on-oauth2-across-many-sites-in-kubernetes/
### https://alikhil.github.io/2018/05/oauth2-proxy-for-kubernetes-services/


### 1
# kubectl create namespace oauth2

### 2
### Need to Create kubernetes secret with credentials:
# apiVersion: v1
# data:
#   client-id: XXXXXXXXXX
#   client-secret:XXXXXXXXXX
#   cookie-secret: XXXXXXXXXX
# kind: Secret
# metadata:
#   labels:
#     app: oauth2-proxy-secrets
#   name: oauth2-proxy-secrets
#   namespace: oauth2
# type: Opaque


# resource "kubernetes_namespace" "oauth2" {
#   metadata {
#     name = "oauth2"
#   }
# }

resource "helm_release" "oauth2" {

  name          = "oauth2"
  repository    = "stable"
  chart         = "oauth2-proxy"
  version       = "0.14.0"
  namespace     = "oauth2"
  recreate_pods = true

  values = [
    "${file("${path.module}/values.yml")}",
  ]

  set {
    name  = "extraArgs.cookie-domain"
    value = ".${var.domain}"
  }

  set {
    name  = "extraArgs.whitelist-domain"
    value = ".${var.domain}"
  }

  set {
    name  = "ingress.hosts[0]"
    value = "oauth2.${var.domain}"
  }

  set {
    name  = "ingress.tls[0].secretName"
    value = "oauth2-noc-tls"
  }

  set {
    name  = "ingress.tls[0].hosts[0]"
    value = "oauth2.${var.domain}"
  }
}
