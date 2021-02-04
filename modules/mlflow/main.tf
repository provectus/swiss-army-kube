

resource local_file mlflow_def {
  content = local.mlflow_def
  filename = "${path.root}/${var.argocd.path}/mlflow-defs/mlflow_def.yaml"
}


resource local_file namespace {
  content = local.namespace
  filename = "${path.root}/${var.argocd.path}/mlflow-namespace.yaml"
}




resource local_file mlflow {
  content = yamlencode({
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "mlflow"
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = "mlflow"
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = var.argocd.repository
        "targetRevision" = var.argocd.branch
        "path"           = "${var.argocd.full_path}/mlflow-defs"
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
  filename = "${path.root}/${var.argocd.path}/mlflow.yaml"
}
