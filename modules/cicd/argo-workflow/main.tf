# Create namespace argo-workflow
resource "kubernetes_namespace" "argo-workflow" {
  depends_on = [
    var.module_depends_on
  ]
  metadata {
    name = "argo-workflow"
  }
}

resource "helm_release" "argo-workflow" {
  depends_on = [
    var.module_depends_on
  ]

  name          = "argo-workflow"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo"
  version       = "0.9.4"
  namespace     = "argo-workflow"
  recreate_pods = true

  set {
    name  = "controller.workflowNamespaces[0]"
    value = "argo-events"
  }

  set {
    name  = "artifactRepository.s3.bucket"
    value = var.aws_s3_bucket
  }

  set {
    name  = "artifactRepository.s3.endpoint"
    value = "s3.${var.aws_region}.amazonaws.com"
  }

  set {
    name  = "artifactRepository.s3.region"
    value = var.aws_region
  }

  values = [
    file("${path.module}/values.yml")
  ]
}
