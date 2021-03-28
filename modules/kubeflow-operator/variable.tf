variable "domain" {
  type        = string
  description = "A domain name that would be assigned to Kubeflow installation"
}

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


variable "pipelines_role_to_assume_role_arn" {
  type        = string
  description = "The ARN of the role to be attached to pipelines workflows."
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

variable "ingress_annotations" {
  type        = map(string)
  description = "A set of annotations for Kubeflow Ingress"
  default     = {}
}

variable "repository" {
  type        = string
  description = "The repository from which to roll out the Kubeflow manifests"
  default     = "https://github.com/kubeflow/manifests"
}

variable "ref" {
  type        = string
  description = "The reference (commit/branch/tag) from which to roll out the Kubeflow manifests"
  default     = "v1.2-branch"
}

variable "namespace" {
  type        = string
  description = "The default name of the namespace to deploy to"
  default     = "kubeflow"
}


variable "namespace_def" {
  type        = string
  description = "The Namespace resource definition"
  default     = null //default is constructed dynmaically. See locals.tf
}


variable "ingress" {
  type        = string
  description = "The Ingress resource definition"
  default     = null //default is constructed dynmaically. See locals.tf
}

variable "issuer" {
  type        = string
  description = "The Issuer resource definition"
  default     = null //default is constructed dynmaically. See locals.tf
}

variable "kfdef" {
  type        = string
  description = "The KfDef resouce definition"
  default     = null //default is constructed dynmaically. See locals.tf
}

variable "rds_username" {
  type        = string
  description = "Username of the RDS database that Kubeflow uses as its backend"
  default     = ""
}

variable "rds_password" {
  type        = string
  description = "Password of the RDS database that Kubeflow uses as its backend"
  default     = ""
}


variable "rds_host" {
  type        = string
  description = "Endpoint of the RDS database that Kubeflow uses as its backend"
}

variable "rds_port" {
  type        = string
  description = "Endpoint of the RDS database that MLFlKubeflowow uses as its backend"
}

variable "s3_bucket_name" {
  type        = string
  description = "Bucket where Kubeflow Pipelines artifacts will be stored"
}

variable "s3_user_access_key" {
  type = map(string)
  default = {
    id : ""
    secret : ""
  }
}

variable "db_name_pipelines" {
  type        = string
  description = "Name of the database on the RDS instance that is used for pipelines"
  default     = "mlpipeline"
}

variable "db_name_cache" {
  type        = string
  description = "Name of the database on the RDS instance that is used for cache"
  default     = "cachedb"
}

variable "db_name_metadata" {
  type        = string
  description = "Name of the database on the RDS instance that is used for metadata"
  default     = "metadb"
}

variable "db_name_katib" {
  type        = string
  description = "Name of the database on the RDS instance that is used for katib"
  default     = "katib"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}
