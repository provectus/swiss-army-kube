resource "helm_release" "aws-efs-csi-driver" {
  depends_on = [
    var.module_depends_on
  ]

  name       = "aws-efs-csi-driver"
  namespace  = "kube-system"
  chart = local.aws-efs-csi-driver-url
  version = local.aws-efs-csi-driver-version
}

resource "aws_efs_mount_target" "this" {
  count          = length(var.vpc.private_subnets) > 0 ? length(var.vpc.private_subnets) : 0
  file_system_id = aws_efs_file_system.this.id
  subnet_id      = var.vpc.private_subnets[count.index]
}

resource "aws_efs_file_system" "this" {
  creation_token = var.cluster_name
}

locals {
  aws-efs-csi-driver-version = "1.0.0"
  aws-efs-csi-driver-url = "https://github.com/kubernetes-sigs/aws-efs-csi-driver/releases/download/v${local.aws-efs-csi-driver-version}/helm-chart.tgz"
}