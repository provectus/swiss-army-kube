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
  config_path = "./kubeconfig_${var.cluster_name}"
}