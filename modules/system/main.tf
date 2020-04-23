data "aws_region" "current" {}

# OIDC cluster EKS settings
resource "aws_iam_openid_connect_provider" "cluster" {
  depends_on = [
    var.module_depends_on
  ]
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  url             = var.cluster_oidc_url
}

data "aws_iam_policy_document" "external_dns_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_oidc_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:external-dns"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.cluster.arn]
      type        = "Federated"
    }
  }
}

# Create role for external_dns
resource "aws_iam_role" "external_dns" {
  depends_on = [
    var.module_depends_on
  ]
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume_role_policy.json
  name               = var.cluster_name

  tags = {
    Environment = var.environment
    Project     = var.project
  }

}

# Create policy for cert_manager
resource "aws_iam_policy" "cert_manager" {
  depends_on = [
    var.module_depends_on
  ]
  name = "${var.cluster_name}_route53_dns_manager"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "route53:GetChange",
          "Resource" : "arn:aws:route53:::change/*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "route53:ChangeResourceRecordSets",
            "route53:ListResourceRecordSets"
          ],
          "Resource" : "arn:aws:route53:::hostedzone/*"
        },
        {
          "Effect" : "Allow",
          "Action" : "route53:ListHostedZonesByName",
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "route53:ListHostedZones",
          "Resource" : "*"
        }
      ]
    }
  )
}

# Create role for cert_manager
resource "aws_iam_role" "cert_manager" {
  depends_on = [
    var.module_depends_on
  ]
  name        = "${var.cluster_name}_dns_manager"
  description = "Role for manage dns by cert-manager"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          },
          "Effect" : "Allow",
          "Sid" : ""
        }
      ]
    }
  )

}

# Attach policy cert_manager to role cert_manager
resource "aws_iam_role_policy_attachment" "cert_manager" {
  depends_on = [
    var.module_depends_on,
    aws_iam_policy.cert_manager
  ]
  role       = aws_iam_role.cert_manager.name
  policy_arn = aws_iam_policy.cert_manager.arn
}

# Attach policy external_dns to role external_dns
resource "aws_iam_role_policy_attachment" "external_dns" {
  depends_on = [
    var.module_depends_on,
    aws_iam_policy.cert_manager,
    aws_iam_role.external_dns
  ]
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.cert_manager.arn
}

# Install Bitnami Helm repository
data "helm_repository" "bitnami" {
  name = "bitnami"
  url  = "https://charts.bitnami.com/bitnami"
}

# Deploy external_dns to manage route53 domain zone
resource "helm_release" "external-dns" {
  depends_on = [
    var.module_depends_on,
    aws_iam_role.cert_manager
  ]
  repository = data.helm_repository.bitnami.metadata[0].name
  name       = "external-dns"
  chart      = "external-dns"
  version    = "2.20.12"
  namespace  = "kube-system"

  values = [
    file("${path.module}/values/external-dns.yaml"),
  ]

  dynamic "set" {
    for_each = var.domains
    content {
      name  = "domainFilters[${set.key}]"
      value = "${set.value}"
    }
  }

  set {
    name  = "aws.region"
    value = data.aws_region.current.name
  }
}

# Create namespace cert-manager
resource "kubernetes_namespace" "cert-manager" {
  depends_on = [
    var.module_depends_on
  ]
  metadata {
    labels = {
      "certmanager.k8s.io/disable-validation" = "true"
    }

    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager_crd" {
  depends_on = [
    kubernetes_namespace.cert-manager,
    aws_iam_role.cert_manager,
    var.module_depends_on
  ]
  name      = "cert-manager-crd"
  chart     = "${path.module}/../../charts/cert-manager-crd"
  namespace = kubernetes_namespace.cert-manager.metadata[0].name
}

# Deploy clusterissuer with route53 dns challenge
resource "helm_release" "issuers" {
  depends_on = [
    helm_release.cert_manager_crd,
    var.module_depends_on
  ]
  name      = "cluster-issuers"
  chart     = "${path.module}/../../charts/cluster-issuers"
  namespace = kubernetes_namespace.cert-manager.metadata[0].name

  set {
    name  = "eks.amazonaws.com/role-arn"
    value = aws_iam_role.cert_manager.arn
  }

  set {
    name  = "email"
    value = var.cert_manager_email
  }

  set {
    name  = "region"
    value = data.aws_region.current.name
  }
}

# Install Jetstack Helm repository
data "helm_repository" "jetstack" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

# Deploy cert-manager (ingress certificate manager)
resource "helm_release" "cert-manager" {
  depends_on = [
    helm_release.issuers,
    kubernetes_namespace.cert-manager,
    var.module_depends_on
  ]
  repository    = data.helm_repository.jetstack.metadata[0].name
  name          = "cert-manager"
  chart         = "cert-manager"
  namespace     = kubernetes_namespace.cert-manager.metadata[0].name
  recreate_pods = true
  version       = "v0.14.2"

  values = [
    file("${path.module}/values/cert-manager.yaml"),
  ]
}

# Deploy kube-state-metrics chart
resource "helm_release" "kube-state-metrics" {
  depends_on = [
    helm_release.issuers,
    helm_release.cert-manager,
    var.module_depends_on
  ]

  name          = "state"
  repository    = "stable"
  chart         = "kube-state-metrics"
  version       = "2.8.2"
  namespace     = "kube-system"
  recreate_pods = true

}

# Deploy saled-secrets
resource "helm_release" "sealed-secrets" {
  depends_on = [
    var.module_depends_on
  ]
  name          = "sealed-secrets"
  repository    = "stable"
  chart         = "sealed-secrets"
  version       = "1.8.0"
  namespace     = "kube-system"
  recreate_pods = true

  values = [
    "${file("${path.module}/values/sealed-secrets.yaml")}",
  ]
}
