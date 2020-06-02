resource "local_file" "api-service" {
  content  = <<-EOT
DB_HOST=${aws_rds_cluster.db.endpoint}
DB_USER=${aws_rds_cluster.db.master_username}
DB_PASSWORD=${aws_rds_cluster.db.master_password}
DB_NAME=${aws_rds_cluster.db.database_name}
STORAGE_REGION=${data.aws_region.this.id}
STORAGE_HOST=s3.${data.aws_region.this.id}.amazonaws.com
STORAGE_BUCKET=${aws_s3_bucket.artifacts.id}
EOT 
  filename = "${path.module}/kustomize/api-service/base/params.env"
}
