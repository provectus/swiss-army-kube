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

variable "aws_private" {
  type        = string
  description = "Use private zone or public"
}

variable "mainzoneid" {
  type        = string
  description = "ID of main route53 zone if exist"
}

variable "domains" {
  description = "domains name for ingress"
}

variable "network" {
  description = "Number would be used to template CIDR 10.X.0.0/16."
}

variable "admin_arns" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
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

variable "on_demand_min_cluster_size" {
  type        = number
  description = "Number of max instances."
  default     = 2
}

variable "spot_max_cluster_size" {
  type        = string
  description = "Number of max instances."
  default     = "2"
}

variable "spot_min_cluster_size" {
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
variable "logstash" {
  description = "logstash"
  default     = "false"
}

variable "filebeat" {
  description = "Enable filebeat"
  default     = "true"
}

variable "elasticsearch-curator" {
  description = "Enable elasticsearch-curator"
  default     = "true"
}

variable "failed_limit" {
  description = "elasticsearch-curator failed jobs history limit"
  default     = 2
}

variable "success_limit" {
  description = "elasticsearch-curator successfull jobs history limit"
  default     = 2
}

variable "elasticDataSize" {
  description = "Size of pvc for elastic data"
  default     = "30Gi"
}

#Jenkins
variable "jenkins_password" {
  description = "Password for jenkins admin"
  default     = "password"
}

variable "agent_policy" {
  description = "Policy attached to Jenkins agents IAM role"
  default = ""
}

variable "master_policy" {
  description = "Policy attached to Jenkins master IAM role"
  default = ""
}

#Grafana
variable "grafana_password" {
  description = "Password for grafana admin"
  default     = "password"
}