resource "local_file" "api-service" {
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
EOT 
  filename = "${path.module}/kustomize/api-service/base/params.env"
}


resource "local_file" "metadata" {
  content  = <<-EOT
MYSQL_ALLOW_EMPTY_PASSWORD=true
MYSQL_DATABASE=${aws_rds_cluster.db.database_name}
MYSQL_HOST=${aws_rds_cluster.db.endpoint}
MYSQL_PORT=3306
EOT
  filename = "${path.module}/kustomize/metadata/overlays/db/params.env"
}

resource "local_file" "metadata-secrets" {
  content  = <<-EOT
MYSQL_ROOT_PASSWORD=${aws_rds_cluster.db.master_password}
MYSQL_USER_NAME=${aws_rds_cluster.db.master_username}
EOT
  filename = "${path.module}/kustomize/metadata/overlays/db/secrets.env"
}
