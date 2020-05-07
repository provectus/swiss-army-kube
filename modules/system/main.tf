data "aws_region" "current" {}


data "aws_vpc" "main" {
  id = var.vpc_id
}

# Route53 hostedzone
# TODO: need create ns records in main zone
resource "aws_route53_zone" "cluster" {
  count = var.aws_private == "false" ? length(var.domains) : 0
  name  = element(var.domains, count.index)

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_route53_record" "cluster-ns" {
  count = var.aws_private == "false" ? length(var.domains) : 0
  zone_id = var.mainzoneid
  name    = element(var.domains, count.index)
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.cluster[count.index].name_servers.0}",
    "${aws_route53_zone.cluster[count.index].name_servers.1}",
    "${aws_route53_zone.cluster[count.index].name_servers.2}",
    "${aws_route53_zone.cluster[count.index].name_servers.3}",
  ]
}

resource "aws_route53_zone" "private" {
  count = var.aws_private == "true" ? length(var.domains) : 0
  name = element(var.domains, count.index)
  vpc {
    vpc_id = data.aws_vpc.main.id
  }
}

# OIDC cluster EKS settings
resource "aws_iam_openid_connect_provider" "cluster" {
  depends_on = [
    var.module_depends_on
  ]
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  url             = var.cluster_oidc_url
}

# Enabling IAM Roles for Service Accounts 
data "aws_caller_identity" "current" {}

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
  name   = "${var.cluster_name}_route53_dns_manager"
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
            "Action": [
              "route53:ChangeResourceRecordSets",
              "route53:ListResourceRecordSets"
            ],
            "Resource": "arn:aws:route53:::hostedzone/*"
        },
        {
            "Effect": "Allow",
            "Action": "route53:ListHostedZonesByName",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "route53:ListHostedZones",
            "Resource": "*"
        }        
    ]
}   
EOF
}

# Create role for cert_manager
resource "aws_iam_role" "cert_manager" {
  depends_on = [
    var.module_depends_on
  ]
  name               = "${var.cluster_name}_dns_manager"
  description        = "Role for manage dns by cert-manager"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

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

resource "kubernetes_cluster_role_binding" "tiller" {
  depends_on = [
    kubernetes_service_account.tiller,
    var.module_depends_on
  ]
  metadata {
    name = "tiller-binding"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "tiller"
    namespace = "kube-system"
    api_group = ""
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "cluster-admin"
    api_group = "rbac.authorization.k8s.io"
  }
}

//TODO: нужен таймаут после создания екс - секунд 30 (не успевают стартануть api). Попробовать создавать другие штуки вроде aws_iam_policy
# Create service account for tiller
resource "kubernetes_service_account" "tiller" {
  depends_on = [
    var.module_depends_on
  ]

  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }

  automount_service_account_token = true
}

resource "null_resource" "wait-tiller"{
    provisioner "local-exec" {
    command = "sleep 15"
  }
}

# Deploy custom resources for cert-manager
resource "null_resource" "cert-manager-crd" {
  depends_on = [
    kubernetes_cluster_role_binding.tiller,
    var.module_depends_on
  ]
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${var.config_path} apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.11/deploy/manifests/00-crds.yaml"
  }
}

# Create namespace cert-manager
resource "kubernetes_namespace" "cert-manager" {
  depends_on = [
    null_resource.cert-manager-crd,
    var.module_depends_on
  ]
  metadata {
    labels = {
      "certmanager.k8s.io/disable-validation" = "true"
    }

    name = "cert-manager"
  }
}

# Init helm for update tiller
resource "null_resource" "helm_init" {
  depends_on = [
    var.module_depends_on,
    kubernetes_cluster_role_binding.tiller
  ]
  provisioner "local-exec" {
    command = "helm --kubeconfig ${var.config_path} --service-account tiller init --upgrade"
  }
}

resource "null_resource" "wait-helm"{
    provisioner "local-exec" {
    command = "sleep 15"
  }
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
    aws_iam_role.cert_manager,
    null_resource.wait-helm
  ]
  repository = data.helm_repository.bitnami.metadata[0].name
  name       = "external-dns"
  chart      = "external-dns"
  version    = "2.22.0"
  namespace  = "kube-system"

  values = [
    file("${path.module}/values/external-dns.yaml"),
  ]

  dynamic "set" {
    for_each = var.domains
    content {
      name  = "domainFilters[${set.key}]"
      value = set.value
    }
  }

  set {
    name  = "aws.region"
    value = data.aws_region.current.name
  }
}

# Deploy clusterissuer with route53 dns challenge
resource "helm_release" "issuers" {
  depends_on = [
    null_resource.cert-manager-crd,
    null_resource.wait-helm,
    kubernetes_namespace.cert-manager,
    aws_iam_role.cert_manager,
    var.module_depends_on
  ]
  name      = "issuers"
  chart     = "../charts/cluster-issuers"
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

# Install jetstack Helm repository
data "helm_repository" "jetstack" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

# Deploy cert-manager (ingress certificate manager)
resource "helm_release" "cert-manager" {
  depends_on = [
    helm_release.issuers,
    kubernetes_namespace.cert-manager,
    kubernetes_cluster_role_binding.tiller,
    null_resource.wait-helm,
    var.module_depends_on
  ]

  name          = "cert-manager"
  repository    = data.helm_repository.jetstack.metadata[0].name
  chart         = "cert-manager"
  version       = "v0.13.1"
  namespace     = kubernetes_namespace.cert-manager.metadata[0].name
  recreate_pods = true

  values = [
    file("${path.module}/values/cert-manager.yaml"),
  ]
}

#Stable chart repository
data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

# Deploy kube-state-metrics chart
resource "helm_release" "metrics-server" {
  depends_on = [
    helm_release.issuers,
    helm_release.cert-manager,
    null_resource.wait-helm,
    var.module_depends_on
    ]

  name          = "state"
  repository    = data.helm_repository.stable.metadata[0].name
  chart         = "metrics-server"
  version       = "2.11.1"
  namespace     = "kube-system"

}

# Deploy saled-secrets
resource "helm_release" "sealed-secrets" {
  depends_on = [
    var.module_depends_on,
    null_resource.wait-helm
  ]
  name          = "sealed-secrets"
  repository    = data.helm_repository.stable.metadata[0].name
  chart         = "sealed-secrets"
  version       = "1.9.0"
  namespace     = "kube-system"

  values = [
    "${file("${path.module}/values/sealed-secrets.yaml")}",
  ]
}
