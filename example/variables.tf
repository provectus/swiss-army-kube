variable "aws_region" {
  description = "Name the aws region (us-central-1, us-west-2 and etc.)"
}

# Name of EKS cluster (Not use underscore in naming. S3 backet name issue)
variable "cluster_name" {
  description = "Name of cluster"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of use avilability_zones"
}

#Deploy environment name
variable "environment" {
  type        = string
  description = "Environment Use in tags and annotations for identify EKS cluster"
}

#Deploy project name
variable "project" {
  type        = string
  description = "Project Use in tags and annotations for identify EKS cluster"
}

variable "config_path" {
  description = "The kubernetes config file path"
}

variable "domain" {
  description = "domain name for ingress"
}

variable "network" {
  description = "Number would be used to template CIDR 10.X.0.0/16."
}

variable "admin_arns" {
  type        = list(string)
  description = "ARNs of users which would have admin permissions."
  default     = []
}

variable "cluster_version" {
  type        = string
  description = "Number of desired instances."
}

variable "on_demand_max_cluster_size" {
  type        = number
  description = "Number of max instances."
  default     = 2
}

variable "spot_max_cluster_size" {
  type        = string
  description = "Number of max instances."
  default     = "2"
}

variable "on_demand_desired_capacity" {
  type        = string
  description = "Number of desired instances."
}

variable "spot_desired_capacity" {
  type        = string
  description = "Number of desired instances."
}

variable "on_demand_instance_type" {
  type        = string
  description = "EC2 Instance type"
}

variable "spot_instance_type" {
  type        = string
  description = "EC2 Instance type"
}

variable "spot_price" {
  type    = string
  default = "0.5"
}

#Cert-manager
variable "cert_manager_email" {
  type        = string
  description = "Email to cert-manager"
}

variable "cert_manager_zoneid" {
  type        = string
  description = "Route53 hosted zone ID for manage at cert-manager"
}

#Ingress github auth settings
variable "github-auth" {
  description = "Trigger for enable or disable deploy oauth2-proxy"
}

variable "github-client-id" {
  default     = ""
  description = "Client id for auth github (create it https://github.com/settings/applications/new)"
}

variable "github-client-secret" {
  default     = ""
  description = "Client secrets"
}

variable "cookie-secret" {
  default     = ""
  description = "random_string make gen command python -c 'import os,base64; print base64.b64encode(os.urandom(16))'"
}

variable "github-org" {
  default     = ""
  description = "Github organization"
}

#Kibana preference
variable "elasticDataSize" {
  description = "Size of pvc for elastic data"
  default     = "30Gi"
}