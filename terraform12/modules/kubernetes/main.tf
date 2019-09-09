# resource "aws_iam_policy" "airflow-logs" {
#   name = "${var.cluster_name}-airflow-logs"
#   description = "Access to S3 bucket from Kubernetes airflow logs"

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "AllowS3ActionsInBucket",
#       "Effect": "Allow",
#       "Action": [
#         "s3:*"
#       ],
#       "Resource": ["arn:aws:s3:::${var.cluster_name}-airflow-logs/*"]
#     }
#   ]
# }
# EOF
# }


module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  version      = "5.1.0"
  cluster_name = "${var.cluster_name}"
  subnets      = "${var.private_subnets}"
  vpc_id       = "${var.vpc_id}"

  cluster_version = var.cluster_version

  map_users = var.admin_arns

  workers_additional_policies = [
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
    "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    //"${aws_iam_policy.airflow-logs.arn}",
  ]

  worker_groups = [
    {
      spot_price           = var.spot_price
      instance_type        = var.instance_type
      asg_max_size         = var.max_cluster_size
      asg_desired_capacity = var.desired_capacity
      asg_min_size         = "2"
    },
  ]
}


data "aws_eks_cluster" "ekscluster" {
  name = "${module.eks.cluster_id}"
}

data "aws_eks_cluster_auth" "ekscluster" {
  name = "${module.eks.cluster_id}"
}

provider "kubernetes" {
  host                   = "${data.aws_eks_cluster.ekscluster.endpoint}"
  cluster_ca_certificate = "${base64decode(data.aws_eks_cluster.ekscluster.certificate_authority.0.data)}"
  token                  = "${data.aws_eks_cluster_auth.ekscluster.token}"
  load_config_file       = false
  version                = "1.7"
}

###################

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }

  automount_service_account_token = true
}

resource "kubernetes_cluster_role_binding" "tiller" {
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

provider "helm" {
  version        = "~> 0.9"
  install_tiller  = "true"
  service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
  namespace       = "${kubernetes_service_account.tiller.metadata.0.namespace}"

  kubernetes {
    config_path = "${module.eks.kubeconfig_filename}"
  }
}

### if you have issue with tiller's permissions on your laptop, run it:
### helm init --service-account tiller --upgrade


resource "kubernetes_namespace" "ingress-nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress-nginx" {
  depends_on = ["kubernetes_namespace.ingress-nginx"]

  name          = "ingress-nginx"
  repository    = "stable"
  chart         = "nginx-ingress"
  version       = "1.12.1"
  namespace     = "ingress-nginx"
  recreate_pods = true

  values = [
    "${file("${path.module}/values/ingress-nginx.yml")}",
  ]
}



### Cert manager

### kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.9/deploy/manifests/00-crds.yaml
resource "null_resource" "cert-manager-crd" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${module.eks.kubeconfig_filename} apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.9/deploy/manifests/00-crds.yaml"
  }
}

resource "kubernetes_namespace" "cert-manager" {
  depends_on = ["null_resource.cert-manager-crd"]
  metadata {
    labels = {
      "certmanager.k8s.io/disable-validation" = "true"
    }

    name = "cert-manager"
  }
}

data "helm_repository" "jetstack" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

resource "helm_release" "cert-manager" {
  depends_on = ["kubernetes_namespace.cert-manager", "null_resource.cert-manager-crd"]

  name          = "cert-manager"
  repository    = "jetstack"
  chart         = "cert-manager"
  version       = "v0.9.0"
  namespace     = "cert-manager"
  recreate_pods = true

  values = [
    "${file("${path.module}/values/cert-manager.yml")}",
  ]
}

### ClusterIssuer
resource "helm_release" "issuers" {
  depends_on = ["kubernetes_namespace.cert-manager", "null_resource.cert-manager-crd"]
  name       = "issuers"
  chart      = "${"${path.module}/charts/issuers"}"
  namespace  = "cert-manager"

  set {
    name  = "email"
    value = var.cert_manager_email
  }
}



### External-DNS

resource "kubernetes_namespace" "external-dns" {
  metadata {
    name = "external-dns"
  }
}

resource "helm_release" "external-dns" {
  depends_on = ["kubernetes_namespace.external-dns"]

  name       = "dns"
  repository = "stable"
  chart      = "external-dns"
  version    = "2.4.2"
  namespace  = "external-dns"

  values = [
    "${file("${path.module}/values/external-dns.yml")}",
  ]

  set {
    name  = "domainFilters[0]"
    value = "${var.domain}"
  }
}



### Metrics server

resource "helm_release" "metrics-server" {

  name          = "metrics-server"
  repository    = "stable"
  chart         = "metrics-server"
  version       = "2.8.2"
  namespace     = "kube-system"
  recreate_pods = true

  values = [
    "${file("${path.module}/values/metrics-server.yml")}",
  ]
}



### Sealed secrets

resource "helm_release" "sealed-secrets" {

  name          = "sealed-secrets"
  repository    = "stable"
  chart         = "sealed-secrets"
  version       = "1.4.0"
  namespace     = "kube-system"
  recreate_pods = true

  values = [
    "${file("${path.module}/values/sealed-secrets.yml")}",
  ]
}
