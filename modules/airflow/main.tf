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
  name       = "airflow"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "airflow"
  version    = "6.3.7"
  namespace  = kubernetes_namespace.airflow.metadata[0].name
  recreate_pods = true
  timeout       = 1200


  values = [templatefile("${path.module}/values/airflow.yaml",
    {
      airflow_url         = "airflow.${var.domains[0]}"
      airflow_username    = var.airflow_username
      airflow_password    = var.airflow_password
      airflow_fernetKey   = var.airflow_fernetKey
      postgresql_local    = var.airflow_postgresql_local
      postgresql_host     = var.airflow_postgresql_host
      postgresql_port     = var.airflow_postgresql_port
      postgresql_username = var.airflow_postgresql_username
      postgresql_password = var.airflow_postgresql_password
      postgresql_database = var.airflow_postgresql_database
      redis_local         = var.airflow_redis_local
      redis_host          = var.airflow_redis_host
      redis_port          = var.airflow_redis_port
      redis_username      = var.airflow_redis_username
      redis_password      = var.airflow_redis_password
    })
  ]
}
