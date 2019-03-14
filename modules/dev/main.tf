terraform {
  backend "s3" {
    bucket = "sak-dev-tf-states"
    key    = "k8s/dev/states"
    region = "us-west-2"
    dynamodb_table = "terraform-lock"
  }
}

provider "helm" {}
provider "aws" {}

data "aws_region" "current" {}

resource "aws_iam_user" "harbor_storage" {
  name = "harbor_storage"
}

resource "aws_iam_user_policy" "harbor_storage" {
  name = "harbor_storage_s3_access"
  user = "${aws_iam_user.harbor_storage.name}"

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
  user = "${aws_iam_user.harbor_storage.name}"
}

resource "kubernetes_namespace" "dev" {
    metadata = {
      name = "${var.namespace_name}"
    }
}

resource "helm_repository" "sak_public" {
  name = "sak_public"
  url = "https://s3-us-west-2.amazonaws.com/sak-pub-charts/"
}

resource "helm_release" "harbor" {
  depends_on = ["kubernetes_namespace.dev"]

  name       = "harbor"
  repository = "sak_public"
  chart      = "harbor"
  version    = "1.0.0"
  namespace  = "${var.namespace_name}"
  recreate_pods = "true"

  values = [
    "${file("${path.module}/values/harbor.yaml")}"
  ]
 
  set {
    name  = "persistence.imageChartStorage.s3.region"
    value = "${data.aws_region.current.name}"
  }

  set {
    name  = "persistence.imageChartStorage.s3.bucket"
    value = "${var.bucket_name}"
  }

  set {
    name  = "persistence.imageChartStorage.s3.accesskey"
    value = "${aws_iam_access_key.harbor_storage.id}"
  }

  set {
    name  = "persistence.imageChartStorage.s3.secretkey"
    value = "${aws_iam_access_key.harbor_storage.secret}"
  }

  set {
    name  = "rbac.create"
    value = "${var.rbac_enabled}"
  }
}

resource "helm_release" "gitlab_runner" {
  depends_on = ["kubernetes_namespace.dev"]

  name       = "gitlab-runner"
  repository = "sak_public"
  chart      = "gitlab-runner"
  version    = "0.2.0"
  namespace  = "${var.namespace_name}"

  values = [
    "${file("${path.module}/values/runner.yaml")}"
  ]

  set {
    name  = "rbac.create"
    value = "${var.rbac_enabled}"
  }
}
