data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_region" "current" {}

resource "kubernetes_namespace" "this" {
  count = var.namespace == "" ? 1 - local.argocd_enabled : 0
  metadata {
    name = var.namespace_name
  }
}

resource "local_file" "namespace" {
  count = local.argocd_enabled
  depends_on = [
    var.module_depends_on
  ]
  content = yamlencode({
    "apiVersion" = "v1"
    "kind"       = "Namespace"
    "metadata" = {
      "name" = local.namespace
    }
  })
  filename = "${path.root}/${var.argocd.path}/ns-${local.namespace}.yaml"
}

resource "local_file" "github_runners" {
  count = local.argocd_enabled
  depends_on = [
    var.module_depends_on
  ]
  filename = "${path.root}/${var.argocd.path}/github-runners.yaml"
  content = yamlencode({
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "github-runners"
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = local.namespace
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = var.argocd.project
      "source" = {
        "repoURL"        = var.argocd.repository
        "targetRevision" = var.argocd.branch
        "path"           = "${var.argocd.full_path}/github-runners"
      }
      "syncPolicy" = {
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
      }
    }
  })
}

resource "local_file" "runner" {
  for_each = var.actions_repositories
  depends_on = [
    var.module_depends_on
  ]
  filename = "${path.root}/${var.argocd.path}/github-runners/${each.key}-runner.yaml"
  content = replace(yamlencode({
    "apiVersion" = "actions.summerwind.dev/v1alpha1"
    "kind"       = "RunnerDeployment"
    "metadata" = {
      "name" = "${each.key}-runner"
    }
    "spec" = var.runner_deployment_spec
  }), "%REPOSITORY%", each.value)
}


locals {
  argocd_enabled = length(var.argocd) > 0 ? 1 : 0
  namespace      = coalescelist(var.namespace == "" && local.argocd_enabled > 0 ? [{ "metadata" = [{ "name" = var.namespace_name }] }] : kubernetes_namespace.this, [{ "metadata" = [{ "name" = var.namespace }] }])[0].metadata[0].name
}

resource "helm_release" "this" {
  count = 1 - local.argocd_enabled

  depends_on = [
    var.module_depends_on
  ]

  name          = local.name
  repository    = local.repository
  chart         = local.chart
  version       = var.chart_version
  namespace     = local.namespace
  recreate_pods = true
  timeout       = 1200

  dynamic "set" {
    for_each = local.conf

    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "aws_kms_ciphertext" "github_token" {
  count     = local.argocd_enabled
  key_id    = var.argocd.kms_key_id
  plaintext = base64encode(var.github_token)
}

resource "local_file" "runner_controller" {
  count = local.argocd_enabled
  depends_on = [
    var.module_depends_on
  ]
  filename = "${path.root}/${var.argocd.path}/actions-runner-controller.yaml"
  content  = yamlencode(local.application)
}

resource "local_file" "runner_controller_secret" {
  count = local.argocd_enabled
  depends_on = [
    var.module_depends_on
  ]
  filename = "${path.root}/${var.argocd.path}/actions-runner-controller-secret.yaml"
  content = yamlencode({
    "apiVersion" = "v1"
    "kind"       = "Secret"
    "metadata" = {
      "name"      = "controller-manager"
      "namespace" = local.namespace
    }
    "type" = "Opaque"
    "data" = {
      "github_token" = "KMS_ENC:${aws_kms_ciphertext.github_token[0].ciphertext_blob}:"
    }
  })
}

locals {
  name       = "actions-runner-controller"
  repository = "https://summerwind.github.io/actions-runner-controller"
  chart      = "actions-runner-controller"
  conf       = merge(local.conf_defaults, var.conf)
  conf_defaults = {
    "autoscaling.enabled"       = true
    "autoscaling.maxReplicas"   = 10
    "resources.limits.cpu"      = "100m"
    "resources.limits.memory"   = "300Mi"
    "resources.requests.cpu"    = "100m"
    "resources.requests.memory" = "300Mi"
  }
  application = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = local.name
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = local.namespace
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = var.argocd.project
      "source" = {
        "repoURL"        = local.repository
        "targetRevision" = var.chart_version
        "chart"          = local.chart
        "helm" = {
          "parameters" = values({
            for key, value in local.conf :
            key => {
              "name"  = key
              "value" = tostring(value)
            }
          })
        }
      }
      "syncPolicy" = {
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
      }
    }
  }
}
