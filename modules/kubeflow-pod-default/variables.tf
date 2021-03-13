variable "external_secrets_deployment_role_arn" {
  type  = string
  description = "The ARN of the role attached to the external-secret deployment. This is the role that will by default be assumed if roleArn is not specified in the ExternalSecret kubernetes spec"
}

variable "external_secrets_secret_role_arn" {
  type  = string
  default = ""
  description = "The ARN of the role that should be assumed by the external-secret deployment when creating the MLFlow ExternalSecret. This role must be assumable by the role that has been attached to external-secret deployment's service account. If left blank, a role will be created."
}

variable secret_arn {
  type  = string
  description = "ARN of an external secret to fetch from AWS Secret Manager"  
}


variable secret_key {
  type  = string
  default = "dev-kaas-32/kubeflow/s3_region"
  description = "Key of an external secret to fetch from AWS Secret Manager"  
}


variable name {
  type = string  
  default = "at-test000"
  description = "How the Secret and PodDefault should be named within Kubernetes"
}

variable namespace {
  type = string  
  description = "Namespace where PodDefault should be created"
  default = "juergen-stary"
}

variable cluster_name {
  type = string  
  description = "Name of the EKS cluster"
}