variable argocd {
  type        = map(string)
  description = "A set of variables for enabling ArgoCD"
  default = {
    namespace  = ""
    path       = ""
    repository = ""
    branch     = ""
  }
}


variable "external_secrets_serviceaccount" {
  type        = map(string)
  default = {
    "name" = "external-secrets-kubernetes-external-secrets"
    "namespace" = "kube-system"
  }
}


variable namespace {
  type = string  
  description = "Namespace where MLFlow should be rolled out"
  default = "mlflow"

}
variable cluster_name {
  type = string  
  description = "Name of the EKS cluster"

}
variable secret_prefix {
  type = string
  default = "eks/mlflow/"

}
variable mlflow_def {
  type        = string
  description = "The resource definition for MLFlow"
  default = null //default is constructed dynmaically. See locals.tf
}

variable namespace_def {
  type        = string
  description = "The Namespace definition for MLFlow"
  default     = null //default is constructed dynmaically. See locals.tf
}

variable rds_username {
  type = string
  description = "Username of the RDS database that MLFlow uses as its backend"
  default = ""
}

variable rds_password {
  type = string
  description = "Password of the RDS database that MLFlow uses as its backend"
  default = ""
}


variable rds_host {
  type = string
  description = "Endpoint of the RDS database that MLFlow uses as its backend"
}

variable rds_port {
  type = string
  description = "Endpoint of the RDS database that MLFlow uses as its backend"
}

variable db_name {
  type = string
  description = "Name of the DB on the RDS instance"
}

variable s3_bucket_name {
  type = string
  description = "Bucket where MLFlow artifacts will be stored"
}

variable tags {
  type = map(string)
  default = {}
}
