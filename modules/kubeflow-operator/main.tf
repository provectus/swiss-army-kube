locals {
  repository = "https://github.com/kubeflow/manifests"
  ref        = "v1.1-branch"
  ingress = {
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
  }
}

resource local_file kubeflow_operator {
  content = yamlencode({
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "kubeflow-operator"
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = "operators"
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = "https://github.com/kubeflow/kfctl"
        "targetRevision" = "v1.2-branch"
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
  filename = "${path.root}/${var.argocd.path}/kubeflow-operator.yaml"
}

resource local_file namespace {
  content  = yamlencode(local.namespace)
  filename = "${path.root}/${var.argocd.path}/kubeflow-namespace.yaml"
}

resource local_file kfdef {
  content  = yamlencode(local.kfdef)
  filename = "${path.root}/${var.argocd.path}/kfdefs/v1.1.0.yaml"
}

resource local_file ingress {
  content  = yamlencode(local.ingress)
  filename = "${path.root}/${var.argocd.path}/kfdefs/ingress.yaml"
}

resource local_file issuer {
  content  = yamlencode(local.issuer)
  filename = "${path.root}/${var.argocd.path}/kfdefs/issuer.yaml"
}

resource local_file kubeflow {
  content = yamlencode({
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "kubeflow"
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = "kubeflow"
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = var.argocd.repository
        "targetRevision" = var.argocd.branch
        "path"           = "${var.argocd.full_path}/kfdefs"
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
  filename = "${path.root}/${var.argocd.path}/kubeflow.yaml"
}
