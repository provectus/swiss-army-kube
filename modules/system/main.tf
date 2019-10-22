resource "null_resource" "cert-manager-crd" {
  count = var.cert_manager.enabled == true ? 1 : 0
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${var.config_path} apply -f https://github.com/jetstack/cert-manager/releases/download/v0.11.0/cert-manager.yaml"
  }
}

data "aws_region" "current" {}

resource "kubernetes_namespace" "system" {
  metadata {
    name = var.namespace_name
  }
}

resource "helm_release" "issuers" {
  count      = var.cert_manager.enabled == true ? 1 : 0
  depends_on = ["kubernetes_namespace.system", "null_resource.cert-manager-crd"]
  name       = "issuers"
  chart      = "../../charts/issuers"
  namespace  = "${var.namespace_name}"

  dynamic set {
    for_each = var.cert_manager.parameters

    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "aws_iam_user" "cert_manager" {
  count = var.cert_manager.enabled == true ? 1 : 0
  name  = "${var.cluster_name}_cert_manager"
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
  count = var.cert_manager.enabled == true ? 1 : 0
  user  = aws_iam_user.cert_manager[0].name
}

resource "helm_release" "cert-manager" {
  count      = var.cert_manager.enabled == true ? 1 : 0
  depends_on = ["helm_release.issuers"]

  name          = "cert-manager"
  repository    = "stable"
  chart         = "cert-manager"
  version       = "v0.6.6"
  namespace     = var.namespace_name
  recreate_pods = true

  values = [
    "${file("${path.module}/values/cert-manager.yaml")}"
  ]
}

resource "helm_release" "nginx-ingress" {
  count      = var.nginx_ingress.enabled == true ? 1 : 0
  depends_on = ["kubernetes_namespace.system"]

  name       = "nginx"
  repository = "stable"
  chart      = "nginx-ingress"
  version    = "1.24.3"
  namespace  = var.namespace_name

  values = [
    "${file("${path.module}/values/nginx-ingress.yaml")}"
  ]
}

resource "helm_release" "external-dns" {
  count      = var.external_dns.enabled == true ? 1 : 0
  depends_on = ["kubernetes_namespace.system"]

  name       = "dns"
  repository = "stable"
  chart      = "external-dns"
  version    = "2.9.0"
  namespace  = var.namespace_name

  values = [
    "${file("${path.module}/values/external-dns.yaml")}"
  ]

  set {
    name  = "domainFilters[0]"
    value = var.domain
  }
}

resource "helm_release" "monitoring" {
  count      = var.monitoring.enabled ? 1 : 0
  name       = "prometheus-operator"
  repository = "stable"
  chart      = "prometheus-operator"
  version    = "6.18.0"
  namespace  = "monitoring"

  values = [
    "${file("${path.module}/values/prometheus.yaml")}"
  ]

  set {
    name  = "grafana.ingress.hosts[0]"
    value = "grafana.${var.cluster_name}.${var.domain}"
  }

  set {
    name  = "grafana.ingress.tls[0].hosts[0]"
    value = "grafana.${var.cluster_name}.${var.domain}"
  }
}
