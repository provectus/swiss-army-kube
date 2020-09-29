locals {
  repository = "https://github.com/kubeflow/manifests"
  ref        = "v1.1-branch"
  ingress = {
    "apiVersion" = "networking.k8s.io/v1beta1"
    "kind"       = "Ingress"
    "metadata" = {
      "name"      = "istio-ingress"
      "namespace" = "istio-system"
      "annotations" = {
        "alb.ingress.kubernetes.io/auth-type"        = "cognito"
        "alb.ingress.kubernetes.io/auth-idp-cognito" = "'{\"UserPoolArn\":\"${var.cognito.pool_arn}\",\"UserPoolClientId\":\"${var.cognito.client_id}\", \"UserPoolDomain\":\"${var.cognito.domain}\"}'"
        "alb.ingress.kubernetes.io/certificate-arn"  = var.cognito.certificate_arn
        "alb.ingress.kubernetes.io/listen-ports"     = "'[{\"HTTPS\":443}]'"
      }
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
  }
  issuer = {
    "apiVersion" = "cert-manager.io/v1alpha2"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "kubeflow-self-signing-issuer"
    }
    "spec" = {
      "selfSigned" = {}
    }
  }
  namespace = {
    "apiVersion" = "v1"
    "kind"       = "Namespace"
    "metadata" = {
      "name" = "kubeflow"
      "labels" = {
        "control-plane"   = "kubeflow"
        "istio-injection" = "enabled"
      }
    }
  }
  kfdef = {
    "apiVersion" = "kfdef.apps.kubeflow.org/v1"
    "kind"       = "KfDef"
    "metadata" = {
      "namespace" = "kubeflow"
      "name"      = "sandbox"
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
              "path" = "stacks/kubernetes/application/istio-1-3-1-stack"
            }
          }
          "name" = "istio-stack"
        },
        {
          "kustomizeConfig" = {
            "repoRef" = {
              "name" = "manifests"
              "path" = "stacks/kubernetes/application/cluster-local-gateway-1-3-1"
            }
          }
          "name" = "cluster-local-gateway"
        },
        {
          "kustomizeConfig" = {
            "repoRef" = {
              "name" = "manifests"
              "path" = "istio/istio/base"
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
        }
      ]
      "repos" = [
        {
          "name" = "manifests"
          "uri"  = "https://github.com/kubeflow/manifests/archive/v1.1-branch.tar.gz"
        }
      ]
      "version" = "v1.1-branch"
    }
  }
}

resource local_file kubeflow_operator {
  content = yamlencode({
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "kubeflow-operator"
      "namespace" = "argocd"
    }
    "spec" = {
      "destination" = {
        "namespace" = "operators"
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = "https://github.com/kubeflow/kfctl"
        "targetRevision" = "v1.1-branch"
        "path"           = "deploy"
        "kustomize" = {
          "images" = ["aipipeline/kubeflow-operator=provectuslabs/kubeflow-operator:master"]
        }
      }
      "syncPolicy" = {
        "syncOptions" = [
          "CreateNamespace=true"
        ]
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
      }
    }
  })
  filename = "${path.root}/apps/kubeflow-operator.yaml"
}

resource local_file namespace {
  content  = yamlencode(local.namespace)
  filename = "${path.root}/apps/kubeflow-namespace.yaml"
}

resource local_file kfdef {
  content  = yamlencode(local.kfdef)
  filename = "${path.root}/apps/kfdefs/v1.1.0.yaml"
}

resource local_file ingress {
  content  = yamlencode(local.ingress)
  filename = "${path.root}/apps/kfdefs/ingress.yaml"
}

resource local_file issuer {
  content  = yamlencode(local.issuer)
  filename = "${path.root}/apps/kfdefs/issuer.yaml"
}

resource local_file kubeflow {
  content = yamlencode({
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "kubeflow"
      "namespace" = "argocd"
    }
    "spec" = {
      "destination" = {
        "namespace" = "kubeflow"
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = var.repository
        "targetRevision" = var.branch
        "path"           = "apps/kfdefs"
      }
      "syncPolicy" = {
        "syncOptions" = [
          "CreateNamespace=false"
        ]
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
      }
    }
  })
  filename = "${path.root}/apps/kubeflow.yaml"
}
