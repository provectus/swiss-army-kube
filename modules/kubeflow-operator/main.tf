

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
  content  = yamlencode(var.namespace)
  filename = "${path.root}/${var.argocd.path}/kubeflow-namespace.yaml"
}

resource local_file kfdef {
  content  = yamlencode(var.kfdef)
  filename = "${path.root}/${var.argocd.path}/kfdefs/kfdef.yaml"
}

resource local_file ingress {
  content  = yamlencode(var.ingress)
  filename = "${path.root}/${var.argocd.path}/kfdefs/ingress.yaml"
}

resource local_file issuer {
  content  = yamlencode(var.issuer)
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
