data "aws_region" "current" {}

data "aws_vpc" "main" {
  id = var.vpc_id
}

resource null_resource wait-eks {
  depends_on = [
    var.module_depends_on
  ]
  provisioner local-exec {
    command = "until kubectl --kubeconfig ${path.root}/${var.config_path} -n kube-system get pods >/dev/null 2>&1;do echo 'Waiting for EKS API';sleep 5;done"
  }
}

resource aws_iam_openid_connect_provider cluster {
  depends_on = [
    var.module_depends_on,
    null_resource.wait-eks
  ]
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  url             = var.cluster_oidc_url
}

# Install NVIDIA gpu support
#      resources:
#        limits:
#          nvidia.com/gpu: 2 # requesting 2 GPUs
# WARNING: if you don't request GPUs when using the device plugin with NVIDIA images all the GPUs on the machine will be exposed inside your container.
resource "helm_release" "nvidia" {
  depends_on = [
    helm_release.issuers,
    null_resource.wait-eks,
    var.module_depends_on
  ]

  name          = "nvidia-device-plugin"
  repository    = "https://nvidia.github.io/k8s-device-plugin"
  chart         = "nvidia-device-plugin"
  version       = "0.6.0"
  recreate_pods = true

  values = [
    file("${path.module}/values/nvidia-device-plugin.yaml"),
  ]
}

# Enabling IAM Roles for Service Accounts
data "aws_caller_identity" "current" {}


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
  timeout       = 1200
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
  timeout    = 1200
}

resource "null_resource" "sealed-secrets-crd" {
  depends_on = [
    null_resource.wait-eks
  ]
  provisioner "local-exec" {
    command = <<EOC
kubectl --kubeconfig ${path.root}/${var.config_path} -n kube-system apply -f ${path.module}/manifests/sealed-secrets-crd.yaml
    EOC
  }
}
# Deploy saled-secrets
resource "helm_release" "sealed-secrets" {
  depends_on = [null_resource.sealed-secrets-crd]
  name       = "sealed-secrets"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "sealed-secrets"
  version    = "1.10.3"
  namespace  = "kube-system"
  timeout    = 1200
  values = [
    file("${path.module}/values/sealed-secrets.yaml"),
  ]
}

resource "kubernetes_cluster_role" "cluster_role" {
  depends_on = [
    var.module_depends_on,
    null_resource.wait-eks
  ]

  for_each = { for role in var.cluster_roles : role.cluster_group => role }

  metadata {
    name = "${each.value.cluster_group}-role"
  }

  dynamic "rule" {
    for_each = each.value.roles
    content {
      api_groups = rule.value.role_api_groups
      resources  = rule.value.role_resources
      verbs      = rule.value.role_verbs
    }
  }
}

resource "kubernetes_cluster_role_binding" "cluster_role_binding" {
  depends_on = [
    var.module_depends_on,
    null_resource.wait-eks
  ]

  for_each = { for role in var.cluster_roles : role.cluster_group => role }

  metadata {
    name = "${each.value.cluster_group}-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${each.value.cluster_group}-role"
  }
  subject {
    kind      = "Group"
    name      = "system:${each.value.cluster_group}"
    api_group = "rbac.authorization.k8s.io"
  }
}
