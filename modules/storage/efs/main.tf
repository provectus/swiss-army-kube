resource "helm_release" "aws-efs-csi-driver" {
  name      = "aws-efs-csi-driver"
  chart     = "${path.module}/../../../charts/aws-efs-csi-driver"
  namespace = "kube-system"
}

resource "aws_efs_mount_target" "this" {
  for_each       = toset(var.vpc.private_subnets)
  file_system_id = "${aws_efs_file_system.this.id}"
  subnet_id      = "${each.key}"
}

resource "aws_efs_file_system" "this" {
  creation_token = var.cluster_name
}
