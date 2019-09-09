variable "environment" {}
variable "private_subnets" {}
variable "vpc_id" {}

resource "aws_efs_file_system" "efs-nexus" {

  creation_token = "${var.environment}-nexus"

  tags = {
    Name = "${var.environment}-nexus"
    Product = "Airflow"
    Environment = var.environment
  }
}

resource "aws_security_group" "ingress-efs" {
  name = "${var.environment}-ingress-efs"
  vpc_id = var.vpc_id

  // NFS
  ingress {
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

    // Terraform removes the default rule
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }
}

resource "aws_efs_mount_target" "nexus-private" {
  count    = "${length(var.private_subnets)}"

  file_system_id  = "${aws_efs_file_system.efs-nexus.id}"
  subnet_id       = var.private_subnets[count.index]
  security_groups = ["${aws_security_group.ingress-efs.id}"]
}



# helm install stable/efs-provisioner \
# --set efsProvisioner.efsFileSystemId=fs-d41636ad \
# --set efsProvisioner.awsRegion=us-east-2
resource "helm_release" "efs-provisioner" {

  name          = "efs-provisioner"
  repository    = "stable"
  chart         = "efs-provisioner"
  version       = "0.7.0"
  namespace     = "nexus"
  recreate_pods = true

  set {
    name  = "efsProvisioner.efsFileSystemId"
    value = "${aws_efs_file_system.efs-nexus.id}"
  }

  set {
    name  = "global.deployEnv"
    value = var.environment
  }

  set {
    name  = "efsProvisioner.awsRegion"
    value = "us-east-2"
  }

  values = [
    "${file("${path.module}/values/efs-provisioner.yml")}",
  ]
}


resource "helm_release" "nexusrm" {

  name          = "nexusrm"
  repository    = "stable"
  chart         = "sonatype-nexus"
  version       = "1.19.0"
  namespace     = "nexus"
  recreate_pods = true

  values = [
    "${file("${path.module}/values/nexusrm.yml")}",
  ]
}
