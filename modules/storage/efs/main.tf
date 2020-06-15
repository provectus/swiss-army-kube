resource "helm_release" "aws-efs-csi-driver" {
  depends_on = [
    var.module_depends_on
  ]
  name      = "aws-efs-csi-driver"
  chart     = "${path.module}/../../../charts/aws-efs-csi-driver"
  namespace = "kube-system"
}

resource "aws_efs_mount_target" "this" {
  count           = length(var.vpc.private_subnets) > 0 ? length(var.vpc.private_subnets) : 0
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.vpc.private_subnets[count.index]
}

resource "aws_efs_file_system" "this" {
  creation_token = var.cluster_name
}
