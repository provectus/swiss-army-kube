module "infrastructure" {
  source = "../modules/infrastructure"

  cluster_size = "${var.cluster_size}"
  cluster_name = "test"
  region       = "${var.region}"
}

module "system" {
  source = "../modules/system"

  cluster_name = "${var.cluster_name}"
  domain = "${var.domain}"
  config_path = "${path.module}/kubeconfig_${var.cluster_name}"
}

module "nginx" {
  source = "../modules/ingress/nginx"

  cluster_name = "${var.cluster_name}"
  config_path = "${path.module}/kubeconfig_${var.cluster_name}"
}

module "prometheus" {
  source = "../modules/monitoring/prometheus"

  cluster_name = "${var.cluster_name}"
  domain = "${var.domain}"
  config_path = "${path.module}/kubeconfig_${var.cluster_name}"
}

module "loki" {
  source = "../modules/logging/loki"

  cluster_name = "${var.cluster_name}"
  domain = "${var.domain}"
  config_path = "${path.module}/kubeconfig_${var.cluster_name}"
}