data "helm_repository" "argo" {
  name = "argo"
  url  = "https://argoproj.github.io/argo-helm"
}

resource "helm_release" "argo-workflow" {
  depends_on = [
    var.module_depends_on
  ]

  name          = "argo-workflow"
  repository    = "argo"
  chart         = "argo"
//  version       = "0.6.3"
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
