variable domain {
  type        = string
  description = "A domain name that would be assigned to Kubeflow installation"
}

variable argocd {
  type        = map(string)
  description = "A set of variables for enabling ArgoCD"
  default = {
    namespace  = ""
    path       = ""
    repository = ""
    branch     = ""
  }
}

variable ingress_annotations {
  type        = map(string)
  description = "A set of annotations for Kubeflow Ingress"
  default     = {}
}

variable repository {
  type        = string
  description = "The repository from which to roll out the Kubeflow manifests"
  default     = "https://github.com/kubeflow/manifests"
}

variable ref {
  type        = string
  description = "The reference (commit/branch/tag) from which to roll out the Kubeflow manifests"
  default     = "v1.2-branch"
}

variable namespace {
  type        = string
  description = "The Namespace resource definition"
  default     = yamlencode({
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
}


variable ingress {
  type        = string
  description = "The Ingress resource definition"
  default = null
}

variable issuer {
  type        = string
  description = "The Issuer resource definition"
  default = yamlencode({
    "apiVersion" = "cert-manager.io/v1alpha2"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "kubeflow-self-signing-issuer"
    }
    "spec" = {
      "selfSigned" = {}
    }
  })
}

variable kfdef {
  type        = string
  description = "The KfDef resouce definition"
  default     = yamlencode({
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


  


  
