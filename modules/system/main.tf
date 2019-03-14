terraform {
  backend "s3" {
    bucket = "sak-dev-tf-states"
    key    = "k8s/system/states"
    region = "us-west-2"
    dynamodb_table = "terraform-lock"
  }
}

provider "kubernetes" {}
provider "helm" {}
provider "aws" {}

resource "helm_repository" "incubator" {
    name = "incubator"
    url  = "https://kubernetes-charts-incubator.storage.googleapis.com"
}

resource "null_resource" "cert-manager-crd" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml"
  }
}

data "aws_region" "current" {}

resource "kubernetes_namespace" "system" {
  metadata {
    labels {
      "certmanager.k8s.io/disable-validation" = "true"
    }
    name = "${var.namespace_name}"
  }
}

resource "helm_release" "issuers" {
  depends_on = ["kubernetes_namespace.system","null_resource.cert-manager-crd"]
  name       = "issuers"
  chart      = "${path.module}/../../charts/issuers"
  namespace  = "${var.namespace_name}"

  set {
    name  = "email"
    value = "rgimadiev@provectus.com"
  }

  set {
    name  = "accessKeyID"
    value = "${aws_iam_access_key.cert_manager.id}"
  }

  set {
    name  = "region"
    value = "${data.aws_region.current.name}"
  }
}

resource "aws_iam_user" "cert_manager" {
  name = "cert_manager"
}

resource "aws_iam_user_policy" "cert_manager" {
  name = "route53_access"
  user = "${aws_iam_user.cert_manager.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "route53:GetChange",
            "Resource": "arn:aws:route53:::change/*"
        },
        {
            "Effect": "Allow",
            "Action": "route53:ChangeResourceRecordSets",
            "Resource": "arn:aws:route53:::hostedzone/*"
        },
        {
            "Effect": "Allow",
            "Action": "route53:ListHostedZonesByName",
            "Resource": "*"
        }
    ]
}   
EOF
}

resource "aws_iam_access_key" "cert_manager" {
  user = "${aws_iam_user.cert_manager.name}"
}

resource "kubernetes_secret" "cert_manager" {
  "metadata" {
    name = "route53-config"
    namespace = "${var.namespace_name}"
  }

  data {
    secret-access-key = "${aws_iam_access_key.cert_manager.secret}"
  }
}

resource "helm_release" "cert-manager" {
  depends_on = ["helm_release.issuers"]

  name       = "cert-manager"
  repository = "stable"
  chart      = "cert-manager"
  version    = "v0.6.5"
  namespace  = "${var.namespace_name}"
  recreate_pods = true
 
  values = [
    "${file("values/cert-manager.yaml")}"
  ]

  set {
    name  = "webhook.enabled"
    value = "true"
  }

  set {
    name  = "rbac.create"
    value = "${var.rbac_enabled}"
  }

  set {
    name  = "ingressShim.defaultACMEChallengeType"
    value = "dns01"
  }

  set {
    name  = "ingressShim.defaultACMEDNS01ChallengeProvider"
    value = "route53"
  }

  set {
    name = "ingressShim.defaultIssuerKind"
    value = "ClusterIssuer"
  }

  set {
    name = "ingressShim.defaultIssuerName"
    value = "letsencrypt-staging" 
  }
}

resource "helm_release" "nginx-ingress" {
  depends_on = ["kubernetes_namespace.system"]

  name       = "nginx"
  repository = "stable"
  chart      = "nginx-ingress"
  version    = "1.3.1"
  namespace  = "${var.namespace_name}"

  values = [
    "${file("values/nginx-ingress.yaml")}"
  ]

  set {
    name  = "rbac.create"
    value = "${var.rbac_enabled}"
  }
}

resource "helm_release" "external-dns" {
  depends_on = ["kubernetes_namespace.system"]

  name       = "dns"
  repository = "stable"
  chart      = "external-dns"
  version    = "1.6.1"
  namespace  = "${var.namespace_name}"

  values = [
    "${file("values/external-dns.yaml")}"
  ]  

  set {
    name  = "rbac.create"
    value = "${var.rbac_enabled}"
  }
}
