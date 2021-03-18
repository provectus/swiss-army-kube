

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

namespace = var.namespace != null ? var.namespace : yamlencode({
    "apiVersion" = "v1"
    "kind"       = "Namespace"
    "metadata" = {
      "name" = "kubeflow"
      "labels" = {
        "control-plane"   = "kubeflow"
        "istio-injection" = "enabled"
      }
    }
  })

issuer = var.issuer != null ? var.issuer : yamlencode({
    "apiVersion" = "cert-manager.io/v1alpha2"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "kubeflow-self-signing-issuer"
    }
    "spec" = {
      "selfSigned" = {}
    }
  })

kfdef = var.kfdef != null ? var.kfdef : yamlencode({
    "apiVersion" = "kfdef.apps.kubeflow.org/v1"
    "kind"       = "KfDef"
    "metadata" = {
      "namespace" = "kubeflow"
      "name"      = "kubeflow"
    }
    "spec" = {
      "applications" = [
        {
          "kustomizeConfig" = {
            "repoRef" = {
              "name" = "manifests"
              "path" = "application/v3"
            }
          }
          "name" = "application"
        },
        {
          "kustomizeConfig" = {
            "repoRef" = {
              "name" = "manifests"
              "path" = "stacks/aws/application/istio-stack"
            }
          }
          "name" = "istio-stack"
        },
        {
          "kustomizeConfig" = {
            "repoRef" = {
              "name" = "manifests"
              "path" = "stacks/aws/application/cluster-local-gateway"
            }
          }
          "name" = "cluster-local-gateway"
        },
        {
          "kustomizeConfig" = {
            "repoRef" = {
              "name" = "manifests"
              "path" = "stacks/aws/application/istio"
            }
          }
          "name" = "istio"
        },
        {
          "kustomizeConfig" = {
            "repoRef" = {
              "name" = "manifests"
              "path" = "metacontroller/base"
            }
          }
          "name" = "metacontroller"
        },
        {
          "kustomizeConfig" = {
            "repoRef" = {
              "name" = "manifests"
              "path" = "admission-webhook/bootstrap/overlays/application"
            }
          }
          "name" = "bootstrap"
        },
        {
          "kustomizeConfig" = {
            "repoRef" = {
              "name" = "manifests"
              "path" = "stacks/kubernetes"
            }
          }
          "name" = "kubeflow-apps"
        },
        {
          "kustomizeConfig" = {
            "repoRef" = {
              "name" = "manifests"
              "path" = "knative/installs/generic"
            }
          }
          "name" = "knative"
        },
        {
          "kustomizeConfig" = {
            "repoRef" = {
              "name" = "manifests"
              "path" = "kfserving/installs/generic"
            }
          }
          "name" = "kfserving"
        },
        {
          "kustomizeConfig" = {
            "repoRef" = {
              "name" = "manifests"
              "path" = "aws/aws-istio-authz-adaptor/base_v3"
            }
          }
          "name" = "aws-istio-authz-adaptor"
        }
      ]
      "repos" = [
        {
          "name" = "manifests"
          "uri"  = "https://github.com/kubeflow/manifests/archive/v1.2-branch.tar.gz"
        }
      ]
      "version" = "v1.2-branch"
    }
  })  
}