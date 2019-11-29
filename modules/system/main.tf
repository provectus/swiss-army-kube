data "helm_repository" "incubator" {
  name = "incubator"
  url  = "https://kubernetes-charts-incubator.storage.googleapis.com"
}

resource "null_resource" "tiller-rbac" {
  provisioner "local-exec" {
    command = <<EOT
      kubectl --kubeconfig ${var.config_path} create serviceaccount -n kube-system tiller;
      kubectl --kubeconfig ${var.config_path} create clusterrolebinding tiller-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:tiller;
      kubectl --kubeconfig ${var.config_path} --namespace kube-system patch deploy tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}';
      helm --kubeconfig ${var.config_path} init --service-account tiller --upgrade
    EOT
  }
}

resource "null_resource" "cert-manager-crd" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${var.config_path} apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml"
  }
}

data "aws_region" "current" {
}

resource "kubernetes_namespace" "system" {
  metadata {
    labels = {
      "certmanager.k8s.io/disable-validation" = "true"
    }
    name = var.namespace_name
  }
}

resource "helm_release" "issuers" {
  depends_on = [
    kubernetes_namespace.system,
    null_resource.cert-manager-crd,
    null_resource.tiller-rbac
  ]
  name      = "issuers"
  chart     = "../../charts/issuers"
  namespace = var.namespace_name

  set {
    name  = "email"
    value = "rgimadiev@provectus.com"
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
}

resource "aws_iam_user" "cert_manager" {
  name = "${var.cluster_name}_cert_manager"
}

resource "aws_iam_user_policy" "cert_manager" {
  name = "${var.cluster_name}_route53_access"
  user = aws_iam_user.cert_manager.name

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
  user = aws_iam_user.cert_manager.name
}

resource "helm_release" "cert-manager" {
  depends_on = [helm_release.issuers,null_resource.tiller-rbac]

  name          = "cert-manager"
  repository    = "stable"
  chart         = "cert-manager"
  version       = "v0.6.6"
  namespace     = var.namespace_name
  recreate_pods = true

  values = [
    file("${path.module}/values/cert-manager.yaml"),
  ]
}

resource "helm_release" "nginx-ingress" {
  depends_on = [kubernetes_namespace.system,null_resource.tiller-rbac]

  name       = "nginx"
  repository = "stable"
  chart      = "nginx-ingress"
  version    = "1.3.1"
  namespace  = var.namespace_name

  values = [
    file("${path.module}/values/nginx-ingress.yaml"),
  ]
}

resource "helm_release" "external-dns" {
  depends_on = [kubernetes_namespace.system,null_resource.tiller-rbac]

  name       = "dns"
  repository = "stable"
  chart      = "external-dns"
  version    = "1.6.1"
  namespace  = var.namespace_name

  values = [
    file("${path.module}/values/external-dns.yaml"),
  ]

  set {
    name  = "domainFilters[0]"
    value = var.domain
  }
}

resource "helm_release" "monitoring" {
  depends_on = [kubernetes_namespace.system,null_resource.tiller-rbac]
    
  name       = "prometheus-operator"
  repository = "stable"
  chart      = "prometheus-operator"
  version    = "5.0.10"
  namespace  = "monitoring"

  values = [
    file("${path.module}/values/prometheus.yaml"),
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
