locals {
  ingress = var.ingress != null ? var.ingress : yamlencode({
    "apiVersion" = "networking.k8s.io/v1beta1"
    "kind"       = "Ingress"
    "metadata" = {
      "name"        = "istio-ingress"
      "namespace"   = "istio-system"
      "annotations" = var.ingress_annotations
      "labels" = {
        "app" = "kubeflow"
      }
    }
    "spec" = {
      "tls" = [
        {
          "hosts" = [
            var.domain
          ]
          "secretName" = "kubeflow-tls-certs"
        }
      ]
      "rules" = [
        {
          "host" = var.domain
          "http" = {
            "paths" = [
              {
                "path" = "/*"
                "backend" = {
                  "serviceName" = "istio-ingressgateway"
                  "servicePort" = 80
                }
              }
            ]
          }
        }
      ]
    }
  })

}