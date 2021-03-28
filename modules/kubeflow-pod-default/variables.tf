variable "external_secrets_deployment_role_arn" {
  type        = string
  description = "The ARN of the role attached to the external-secret deployment. This is the role that will by default be assumed if roleArn is not specified in the ExternalSecret kubernetes spec"
}

variable "external_secrets_secret_role_arn" {
  type        = string
  default     = ""
  description = "The ARN of the role that should be assumed by the external-secret deployment when creating the MLFlow ExternalSecret. This role must be assumable by the role that has been attached to external-secret deployment's service account. If left blank, a role will be created."
}

/*
variable key {
  type  = string
  default = ""
  description = "Key of an external secret to fetch from AWS Secret Manager"  
}


variable name {
  type = string  
  default = ""
  description = "How the Secret and PodDefault should be named within Kubernetes"
}
*/

variable "namespace" {
  type        = string
  description = "Namespace where PodDefault should be created"
  default     = ""
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "tags" {
  type    = map(string)
  default = {}
}

/*
variable pod_default_def {
  type        = string
  description = "The resource definition for Pod-Default-Def"
  default = null //default is constructed dynmaically. See main.tf
}
*/

variable "kubeflow_pod-defaults" {
  description = "Adds values to PodDefaults to individual namespaces"
  type = set(object({
    namespace = string
    secret    = string
    name      = string
  }))
  default = []
}

variable "argocd" {
  type        = map(string)
  description = "A set of values for enabling deployment through ArgoCD"
  default     = {}
}
