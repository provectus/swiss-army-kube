data "external" "trigger" {
  program = ["bash", "${path.module}/dir_md5sum.sh"]

  query = {
    directory = "${path.module}/sak_kustomize"
  }
}

resource "local_file" "api-service" {
  depends_on = [
    null_resource.sak_kustomize
  ]
  content  = <<-EOT
DB_HOST=${aws_rds_cluster.db.endpoint}
DB_USER=${aws_rds_cluster.db.master_username}
DB_PASSWORD=${aws_rds_cluster.db.master_password}
DB_NAME=${aws_rds_cluster.db.database_name}
STORAGE_REGION=${data.aws_region.this.id}
STORAGE_HOST=s3.${data.aws_region.this.id}.amazonaws.com
STORAGE_BUCKET=${var.artifacts.id}
STORAGE_KEY=${aws_iam_access_key.this.id}
STORAGE_SECRET=${aws_iam_access_key.this.secret}
# ${null_resource.sak_kustomize.id}
EOT
  filename = "${path.module}/kustomize/api-service/base/params.env"
}


resource "local_file" "metadata" {
  depends_on = [
    null_resource.sak_kustomize
  ]
  content  = <<-EOT
MYSQL_ALLOW_EMPTY_PASSWORD=true
MYSQL_DATABASE=${aws_rds_cluster.db.database_name}
MYSQL_HOST=${aws_rds_cluster.db.endpoint}
MYSQL_PORT=3306
# ${null_resource.sak_kustomize.id}
EOT
  filename = "${path.module}/kustomize/metadata/overlays/db/params.env"
}

resource "local_file" "metadata-secrets" {
  depends_on = [
    null_resource.sak_kustomize
  ]
  content  = <<-EOT
MYSQL_ROOT_PASSWORD=${aws_rds_cluster.db.master_password}
MYSQL_USER_NAME=${aws_rds_cluster.db.master_username}
# ${null_resource.sak_kustomize.id}
EOT
  filename = "${path.module}/kustomize/metadata/overlays/db/secrets.env"
}

resource "null_resource" "kfctl_build" {
  triggers = {
    kfctl = "${sha1(file("${path.module}/kfctl.yaml"))}"
    sak_kustomize_hash = "${data.external.trigger.result["checksum"]}"
  }

  depends_on = [
    aws_iam_role.this,
    aws_rds_cluster.db
  ]
  provisioner "local-exec" {
    command = "cd ${path.module} && rm -rf .cache && rm -rf kustomize && kfctl build -f kfctl.yaml"
  }
}

resource "null_resource" "sak_kustomize" {
  triggers = {
    kfctl_build = null_resource.kfctl_build.id
  }
  depends_on = [
    null_resource.kfctl_build
  ]
  provisioner "local-exec" {
    command = "cp -rf ${path.module}/sak_kustomize/* ${path.module}/kustomize/"
  }
}

resource "null_resource" "kfctl" {
  triggers = {
    api-service      = local_file.api-service.id,
    metadata         = local_file.metadata.id,
    metadata-secrets = local_file.metadata-secrets.id,
  }

  depends_on = [
    var.module_depends_on,
    local_file.api-service,
    local_file.metadata,
    local_file.metadata-secrets
  ]
  provisioner "local-exec" {
    command = "KUBECONFIG=${var.config_path} kfctl apply -f ${path.module}/kfctl.yaml"
  }
}