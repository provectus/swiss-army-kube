resource "helm_release" "aws-efs-csi-driver" {
  depends_on = [
    var.module_depends_on
  ]
  name      = "aws-efs-csi-driver"
  chart     = "${path.module}/../../../charts/aws-efs-csi-driver"
  namespace = "kube-system"
}

resource "aws_efs_mount_target" "this" {
<<<<<<< HEAD
  for_each       = toset(var.vpc.private_subnets)
  file_system_id = "${aws_efs_file_system.this.id}"
  subnet_id      = "${each.key}"
=======
  count           = length(var.vpc.private_subnets) > 0 ? length(var.vpc.private_subnets) : 0
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.vpc.private_subnets[count.index]
>>>>>>> a8a518ab2ee65f6652f44cb2a714280d4a1103f6
}

resource "aws_efs_file_system" "this" {
  creation_token = var.cluster_name
}
