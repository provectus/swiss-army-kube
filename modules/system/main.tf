resource "null_resource" "cert-manager-crd" {
  count = var.cert_manager.enabled == true ? 1 : 0
  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.12/deploy/manifests/00-crds.yaml --validate=false"
  }
}

data "aws_region" "current" {
}

resource "kubernetes_namespace" "system" {
  count = var.namespace_name == "kube-system" ? 0 : 1
  metadata {
    name = var.namespace_name
  }
}

data "helm_repository" "jetstack" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

resource "aws_iam_user" "cert_manager" {
  count = var.cert_manager.enabled == true ? 1 : 0
  name  = "${var.cluster_name}_cert_manager"
}

data "aws_route53_zone" "selected" {
  name = "${var.domain}."
}

resource "aws_iam_user_policy" "cert_manager" {
  count = var.cert_manager.enabled == true ? 1 : 0
  name  = "${var.cluster_name}_route53_access"
  user  = aws_iam_user.cert_manager[0].name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "route53:GetChange",
            "Resource": "arn:aws:route53:::change/${data.aws_route53_zone.selected.zone_id}"
        },
        {
            "Effect": "Allow",
            "Action": "route53:ChangeResourceRecordSets",
            "Resource": "arn:aws:route53:::hostedzone/${data.aws_route53_zone.selected.zone_id}"
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
  count = var.cert_manager.enabled == true ? 1 : 0
  user  = aws_iam_user.cert_manager[0].name
}

locals {
  cert_manager_defaults = {
    "rbac.create"     = true,
    "rbac.pspEnabled" = true,
  }
  external_dns_defaults = {
    "rbac.create"      = true,
    "rbac.pspEnabled"  = true,
    "domainFilters[0]" = var.domain
  }
  nginx_ingress_defaults = {
    "rbac.create"     = true,
    "rbac.pspEnabled" = true,
  }

}

resource "helm_release" "cert-manager" {
  count         = var.cert_manager.enabled == true ? 1 : 0
  name          = "cert-manager"
  repository    = "jetstack"
  chart         = "cert-manager"
  version       = "v0.12.0-beta.1"
  namespace     = var.namespace_name
  recreate_pods = true

  dynamic set {
    for_each = merge(local.cert_manager_defaults, var.cert_manager.parameters)

    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "helm_release" "nginx-ingress" {
  count      = var.nginx_ingress.enabled == true ? 1 : 0
  depends_on = ["kubernetes_namespace.system"]

  name       = "nginx-ingress"
  repository = "stable"
  chart      = "nginx-ingress"
  version    = "1.24.3"
  namespace  = var.namespace_name

  dynamic set {
    for_each = merge(local.nginx_ingress_defaults, var.nginx_ingress.parameters)

    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "helm_release" "external-dns" {
  count      = var.external_dns.enabled == true ? 1 : 0
  depends_on = ["kubernetes_namespace.system"]

  name       = "external-dns"
  repository = "stable"
  chart      = "external-dns"
  version    = "2.9.0"
  namespace  = var.namespace_name

  dynamic set {
    for_each = merge(local.external_dns_defaults, var.external_dns.parameters)

    content {
      name  = set.key
      value = set.value
    }
  }
}

