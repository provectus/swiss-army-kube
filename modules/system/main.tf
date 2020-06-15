data "aws_region" "current" {}


data "aws_vpc" "main" {
  id = var.vpc_id
}

# Wait initial eks
resource "null_resource" "wait-eks" {
  depends_on = [
    var.module_depends_on
  ]
  provisioner "local-exec" {
    command = "until kubectl --kubeconfig ${path.root}/${var.config_path} -n kube-system get pods >/dev/null 2>&1;do echo 'Waiting for EKS API';sleep 5;done"
  }
}

# Route53 hostedzone
# TODO: need create ns records in main zone
resource "aws_route53_zone" "cluster" {
  depends_on = [
    var.module_depends_on,
    null_resource.wait-eks
  ]

  count = var.aws_private == "false" ? length(var.domains) : 0
  name  = element(var.domains, count.index)

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_route53_record" "cluster-ns" {
  depends_on = [
    var.module_depends_on,
    null_resource.wait-eks
  ]
  count   = var.aws_private == "false" ? length(var.domains) : 0
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
  depends_on = [
    var.module_depends_on,
    null_resource.wait-eks
  ]
  count = var.aws_private == "true" ? length(var.domains) : 0
  name  = element(var.domains, count.index)
  vpc {
    vpc_id = data.aws_vpc.main.id
  }
}

# OIDC cluster EKS settings
resource "aws_iam_openid_connect_provider" "cluster" {
  depends_on = [
    var.module_depends_on,
    null_resource.wait-eks
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
    var.module_depends_on,
    null_resource.wait-eks
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
    var.module_depends_on,
    null_resource.wait-eks
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
    var.module_depends_on,
    null_resource.wait-eks
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
    aws_iam_policy.cert_manager,
    null_resource.wait-eks
  ]
  role       = aws_iam_role.cert_manager.name
  policy_arn = aws_iam_policy.cert_manager.arn
}

# Attach policy external_dns to role external_dns
resource "aws_iam_role_policy_attachment" "external_dns" {
  depends_on = [
    var.module_depends_on,
    aws_iam_policy.cert_manager,
    aws_iam_role.external_dns,
    null_resource.wait-eks
  ]
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.cert_manager.arn
}


# Deploy custom resources for cert-manager
resource "null_resource" "cert-manager-crd" {
  depends_on = [
    null_resource.wait-eks,
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
    var.module_depends_on,
    null_resource.wait-eks
  ]
  metadata {
    labels = {
      "certmanager.k8s.io/disable-validation" = "true"
    }

    name = "cert-manager"
  }
}

# Deploy external_dns to manage route53 domain zone
resource "helm_release" "external-dns" {
  depends_on = [
    var.module_depends_on,
    aws_iam_role.cert_manager,
    null_resource.wait-eks
  ]
  repository = "https://charts.bitnami.com/bitnami"
  name       = "external-dns"
  chart      = "external-dns"
  version    = "3.1.0"
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
    null_resource.wait-eks,
    kubernetes_namespace.cert-manager,
    aws_iam_role.cert_manager,
    var.module_depends_on
  ]
  name      = "issuers"
  chart     = "../charts/cluster-issuers"
  version   = "0.1.0"
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

# Deploy cert-manager (ingress certificate manager)
resource "helm_release" "cert-manager" {
  depends_on = [
    helm_release.issuers,
    null_resource.wait-eks,
    var.module_depends_on
  ]

  name          = "cert-manager"
  repository    = "https://charts.jetstack.io"
  chart         = "cert-manager"
  version       = "v0.15.1"
  namespace     = kubernetes_namespace.cert-manager.metadata[0].name
  recreate_pods = true

  values = [
    file("${path.module}/values/cert-manager.yaml"),
  ]
}

# Deploy kube-state-metrics chart
resource "helm_release" "metrics-server" {
  depends_on = [
    null_resource.wait-eks,
    var.module_depends_on
  ]

  name       = "state"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "metrics-server"
  version    = "2.11.1"
  namespace  = "kube-system"

}

# Deploy saled-secrets
resource "helm_release" "sealed-secrets" {
  depends_on = [
    var.module_depends_on,
    null_resource.wait-eks
  ]
  name       = "sealed-secrets"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "sealed-secrets"
  version    = "1.10.1"
  namespace  = "kube-system"

  values = [
    "${file("${path.module}/values/sealed-secrets.yaml")}",
  ]
}
