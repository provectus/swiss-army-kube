

resource "local_file" "kfserving_def" {
  content  = local.kfserving_def
  filename = "${path.root}/${var.argocd.path}/kfserving-defs/kfserving_def.yaml"
}


resource "local_file" "namespace" {
  content  = local.namespace
  filename = "${path.root}/${var.argocd.path}/kfserving-namespace.yaml"
}




resource "local_file" "kfserving" {
  content = yamlencode({
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "kfserving"
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = "kfserving"
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = var.argocd.repository
        "targetRevision" = var.argocd.branch
        "path"           = "${var.argocd.full_path}/kfserving-defs"
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
  filename = "${path.root}/${var.argocd.path}/kfserving.yaml"
}
