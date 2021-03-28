resource "local_file" "profiles" {
  for_each = { for profile in var.profiles : profile.namespace => profile.email }
  content  = <<EOT
apiVersion: kubeflow.org/v1
kind: Profile
metadata:
  name: ${each.key}
spec:
  owner:
    kind: User
    name: ${each.value}
EOT
  filename = "${path.root}/${var.argocd.path}/profiles/profile-${each.key}.yaml"
}


resource "local_file" "profile_application" {
  content = yamlencode({
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "profile"
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
        "path"           = "${var.argocd.full_path}/profiles"
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
  filename = "${path.root}/${var.argocd.path}/profile.yaml"
}
