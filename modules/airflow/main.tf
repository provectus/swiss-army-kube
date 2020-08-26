# Create namespace
resource "kubernetes_namespace" "airflow" {
  depends_on = [
    var.module_depends_on
  ]
  metadata {
    name = "airflow"
  }
}

resource "helm_release" "airflow" {
  depends_on = [
    var.module_depends_on
  ]
  name          = "airflow"
  repository    = "https://charts.bitnami.com/bitnami"
  chart         = "airflow"
  version       = "6.3.7"
  namespace     = kubernetes_namespace.airflow.metadata[0].name
  recreate_pods = true
  timeout       = 1200


  values = [templatefile("${path.module}/values/airflow.yaml",
    {
      airflow_url         = "airflow.${var.domains[0]}"
      airflow_username    = var.airflow_username
      airflow_password    = var.airflow_password != "" ? var.airflow_password : random_password.airflow_password.result
      airflow_fernetKey   = var.airflow_fernetKey
      postgresql_local    = var.airflow_postgresql_local
      postgresql_host     = var.airflow_postgresql_host
      postgresql_port     = var.airflow_postgresql_port
      postgresql_username = var.airflow_postgresql_username
      postgresql_password = var.airflow_postgresql_local ? random_password.airflow_postgresql_password.result : var.airflow_postgresql_password
      postgresql_database = var.airflow_postgresql_database
      redis_local         = var.airflow_redis_local
      redis_host          = var.airflow_redis_host
      redis_port          = var.airflow_redis_port
      redis_username      = var.airflow_redis_username
      redis_password      = var.airflow_redis_local ? random_password.airflow_redis_password.result : var.airflow_redis_password
    })
  ]
}

#Password generator
resource "random_password" "airflow_password" {
  length           = 16
  special          = true
  override_special = "!#%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "airflow_password" {
  name  = "/airflow/${var.cluster_name}/${var.airflow_username}"
  type  = "SecureString"
  value = random_password.airflow_password.result
}

resource "random_password" "airflow_postgresql_password" {
  length           = 16
  special          = true
  override_special = "!#%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "airflow_postgresql_password" {
  name  = "/airflow/${var.cluster_name}/${var.airflow_postgresql_username}"
  type  = "SecureString"
  value = random_password.airflow_postgresql_password.result
}

resource "random_password" "airflow_redis_password" {
  length           = 16
  special          = true
  override_special = "!#%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "airflow_redis_password" {
  name  = "/airflow/${var.cluster_name}/${var.airflow_redis_username}"
  type  = "SecureString"
  value = random_password.airflow_redis_password.result
}