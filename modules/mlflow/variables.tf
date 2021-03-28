variable "argocd" {
  type        = map(string)
  description = "A set of variables for enabling ArgoCD"
  default = {
    namespace  = ""
    path       = ""
    repository = ""
    branch     = ""
  }
}


variable "external_secrets_deployment_role_arn" {
  type        = string
  description = "The ARN of the role attached to the external-secret deployment. This is the role that will by default be assumed if roleArn is not specified in the ExternalSecret kubernetes spec"
}

variable "external_secrets_secret_role_arn" {
  type        = string
  default     = ""
  description = "The ARN of the role that should be assumed by the external-secret deployment when creating the MLFlow ExternalSecret. This role must be assumable by the role that has been attached to external-secret deployment's service account. If left blank, a role will be created."
}



variable "db_name" {
  type        = string
  description = "Name of the database on the RDS instance that is used for mlflow"
  default     = "mlflow"
}

variable "namespace" {
  type        = string
  description = "Namespace where MLFlow should be rolled out"
  default     = "mlflow"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"

}
variable "secret_prefix" {
  type    = string
  default = "eks/mlflow/"

}
variable "mlflow_def" {
  type        = string
  description = "The resource definition for MLFlow"
  default     = null //default is constructed dynmaically. See locals.tf
}

variable "namespace_def" {
  type        = string
  description = "The Namespace definition for MLFlow"
  default     = null //default is constructed dynmaically. See locals.tf
}

variable "rds_username" {
  type        = string
  description = "Username of the RDS database that MLFlow uses as its backend"
  default     = ""
}

variable "rds_password" {
  type        = string
  description = "Password of the RDS database that MLFlow uses as its backend"
  default     = ""
}


variable "rds_host" {
  type        = string
  description = "Endpoint of the RDS database that MLFlow uses as its backend"
}

variable "rds_port" {
  type        = string
  description = "Endpoint of the RDS database that MLFlow uses as its backend"
}

variable "s3_bucket_name" {
  type        = string
  description = "Bucket where MLFlow artifacts will be stored"
}

variable "tags" {
  type    = map(string)
  default = {}
}


