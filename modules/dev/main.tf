data "aws_region" "current" {
}

resource "aws_iam_user" "harbor_storage" {
  name = "${var.cluster_name}_harbor_storage"
}

resource "aws_iam_user_policy" "harbor_storage" {
  name = "harbor_storage_s3_access"
  user = aws_iam_user.harbor_storage.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:ListBucketMultipartUploads"
      ],
      "Resource": "arn:aws:s3:::${var.bucket_name}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListMultipartUploadParts",
        "s3:AbortMultipartUpload"
      ],
      "Resource": "arn:aws:s3:::${var.bucket_name}/*"
    }
  ]
}
EOF

}

resource "aws_iam_access_key" "harbor_storage" {
  user = aws_iam_user.harbor_storage.name
}

resource "kubernetes_namespace" "dev" {
  metadata {
    name = var.namespace_name
  }
}

data "helm_repository" "gitlab" {
  name = "gitlab"
  url  = "https://charts.gitlab.io/"
}

resource "helm_release" "harbor" {
  depends_on = [kubernetes_namespace.dev]

  name          = "harbor"
  chart         = "../../charts/harbor"
  namespace     = var.namespace_name
  recreate_pods = "true"

  values = [
    file("${path.module}/values/harbor.yaml"),
  ]

  set {
    name  = "persistence.imageChartStorage.s3.region"
    value = data.aws_region.current.name
  }

  set {
    name  = "persistence.imageChartStorage.s3.bucket"
    value = var.bucket_name
  }

  set {
    name  = "persistence.imageChartStorage.s3.accesskey"
    value = aws_iam_access_key.harbor_storage.id
  }

  set {
    name  = "persistence.imageChartStorage.s3.secretkey"
    value = aws_iam_access_key.harbor_storage.secret
  }

  set {
    name  = "expose.ingress.hosts.core"
    value = "harbor.${var.cluster_name}.${var.domain}"
  }

  set {
    name  = "expose.ingress.hosts.notary"
    value = "notary.harbor.${var.cluster_name}.${var.domain}"
  }

  set {
    name  = "externalURL"
    value = "http://harbor.${var.cluster_name}.${var.domain}"
  }
}

resource "helm_release" "gitlab_runner" {
  depends_on = [kubernetes_namespace.dev]

  name       = "gitlab-runner"
  repository = "gitlab"
  chart      = "gitlab-runner"
  version    = "0.3.0"
  namespace  = var.namespace_name

  values = [
    file("${path.module}/values/runner.yaml"),
  ]
}

