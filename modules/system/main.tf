#Global helm chart repo
data "helm_repository" "incubator" {
  name = "incubator"
  url  = "https://kubernetes-charts-incubator.storage.googleapis.com"
}

#Cert-manager chart repo
data "helm_repository" "jetstack" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

data "aws_region" "current" {

}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }

  automount_service_account_token = true
}

resource "kubernetes_cluster_role_binding" "tiller" {
  depends_on = [kubernetes_service_account.tiller]
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

resource "null_resource" "helm_init" {
  provisioner "local-exec" {
    command = <<EOT
      kubectl --kubeconfig ${var.config_path} init --upgrade;
      sleep 15
    EOT  
  }
}

resource "helm_release" "external-dns" {
  depends_on = [kubernetes_cluster_role_binding.tiller]

  name       = "dns"
  repository = "stable"
  chart      = "external-dns"
  version    = "2.11.0"
  namespace  = "kube-system"

  values = [
    file("${path.module}/values/external-dns.yaml"),
  ]

  set {
    name  = "domainFilters[0]"
    value = var.domain
  }
}

resource "null_resource" "cert-manager-crd" {
  depends_on = [kubernetes_cluster_role_binding.tiller]
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${var.config_path} apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.11/deploy/manifests/00-crds.yaml"
  }
}

resource "kubernetes_namespace" "cert-manager" {
  depends_on = [null_resource.cert-manager-crd]
  metadata {
    labels = {
      "certmanager.k8s.io/disable-validation" = "true"
    }

    name = "cert-manager"
  }
}

resource "aws_iam_user" "cert_manager" {
  name = "${var.cluster_name}_cert_manager"
}

resource "aws_iam_access_key" "cert_manager" {
  user = aws_iam_user.cert_manager.name
}

resource "aws_iam_role" "cert_manager" {
  name = "${var.cluster_name}_dns_manager"
  description = "Role for manage dns by cert-manager"
  assume_role_policy = <<EOF
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
        }
    ]
 }   
 EOF
}

resource "aws_iam_policy" "cert_manager" {
  name = "${var.cluster_name}_route53_access"

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
        }
    ]
 }   
 EOF

}

resource "helm_release" "issuers" {
  depends_on = [null_resource.cert-manager-crd,kubernetes_namespace.cert-manager,aws_iam_user_policy.cert_manager]
  name      = "issuers"
  chart     = "../charts/cluster-issuers"
  namespace = kubernetes_namespace.cert-manager.metadata[0].name

  set {
    name  = "email"
    value = var.cert_manager_email
  }

  set {
    name  = "accessKeyID"
    value = aws_iam_access_key.cert_manager.id
  }

  set {
    name  = "secretAccessKey"
    value = base64encode(aws_iam_access_key.cert_manager.secret)
  }

  set {
    name  = "region"
    value = data.aws_region.current.name
  }

  set {
    name  = "role"
    value = aws_iam_role.cert_manager.arn
  }

  set {
    name  = "hostedZoneID"
    value = var.cert_manager_zoneid
  }
}

resource "helm_release" "cert-manager" {
  depends_on = [helm_release.issuers,kubernetes_namespace.cert-manager,kubernetes_cluster_role_binding.tiller,aws_iam_user_policy.cert_manager]

  name          = "cert-manager"
  repository    = "jetstack"
  chart         = "cert-manager"
  version       = "v0.11.1"
  namespace     = kubernetes_namespace.cert-manager.metadata[0].name
  recreate_pods = true

  values = [
    file("${path.module}/values/cert-manager.yaml"),
  ]
}

resource "helm_release" "kube-state-metrics" {
  depends_on = [helm_release.issuers,helm_release.cert-manager,kubernetes_cluster_role_binding.tiller]

  name          = "state"
  repository    = "stable"
  chart         = "kube-state-metrics"
  version       = "2.4.1"
  namespace     = "kube-system"
  recreate_pods = true

}

resource "helm_release" "sealed-secrets" {
  depends_on = [kubernetes_cluster_role_binding.tiller]
  name          = "sealed-secrets"
  repository    = "stable"
  chart         = "sealed-secrets"
  version       = "1.4.0"
  namespace     = "kube-system"
  recreate_pods = true

  values = [
    "${file("${path.module}/values/sealed-secrets.yaml")}",
  ]
}
