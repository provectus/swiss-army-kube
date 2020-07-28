variable "aws_region" {
  description = "Name the aws region (us-central-1, us-west-2 and etc.)"
}

# Name of EKS cluster (Not use underscore in naming. S3 backet name issue)
variable "cluster_name" {
  type        = string
  description = "Name of the kubernetes cluster"
  default     = "test"
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

# On-demand instance
variable "on_demand_common_max_cluster_size" {
  type        = string
  description = "Max number of on demand instances in EKS autoscaling group"
  default     = "2"
}

variable "on_demand_common_min_cluster_size" {
  type        = string
  description = "Min number of on demand instances in EKS autoscaling group"
  default     = "1"
}

variable "on_demand_common_desired_capacity" {
  type        = string
  description = "Desired number of on_demand instances in EKS autoscaling group"
  default     = "1"
}

variable "on_demand_common_instance_type" {
  description = "EC2 on_demand Instance type"
  default     = ["m5.large", "m5.xlarge", "m5.2xlarge"]
}

variable "on_demand_common_allocation_strategy" {
  description = "Strategy to use when launching on-demand instances. Valid values: prioritized"
  default     = "null"
}

variable "on_demand_common_base_capacity" {
  description = "Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances"
  default     = "0"

}

variable "on_demand_common_percentage_above_base_capacity" {
  description = "Percentage split between on-demand and Spot instances above the base on-demand capacity"
  default     = "0"
}

variable "on_demand_common_asg_recreate_on_change" {
  description = "Recreate the autoscaling group when the Launch Template or Launch Configuration change."
  default     = "false"
}

# Spot instance
variable "spot_max_cluster_size" {
  type        = string
  description = "Max number of spot instances in EKS autoscaling group"
  default     = "2"
}

variable "spot_min_cluster_size" {
  type        = string
  description = "Min number of spot instances in EKS autoscaling group"
  default     = "0"
}

variable "spot_desired_capacity" {
  type        = string
  description = "Desired number of spot instances in EKS autoscaling group"
  default     = "0"
}

variable "spot_instance_type" {
  description = "EC2 spot Instance type"
  default     = ["m5.large", "m5.xlarge", "m5.2xlarge"]
}

variable "spot_instance_pools" {
  description = "Number of Spot pools per availability zone to allocate capacity. EC2 Auto Scaling selects the cheapest Spot pools and evenly allocates Spot capacity across the number of Spot pools that you specify."
  default     = "10"
}

variable "spot_asg_recreate_on_change" {
  description = "Recreate the autoscaling group when the Launch Template or Launch Configuration change."
  default     = "false"
}

variable "spot_allocation_strategy" {
  description = "Valid options are 'lowest-price' and 'capacity-optimized'. If 'lowest-price', the Auto Scaling group launches instances using the Spot pools with the lowest price, and evenly allocates your instances across the number of Spot pools. If 'capacity-optimized', the Auto Scaling group launches instances using Spot pools that are optimally chosen based on the available Spot capacity."
  default     = "lowest-price"
}

variable "spot_max_price" {
  type        = string
  default     = ""
  description = "Maximum price per unit hour that the user is willing to pay for the Spot instances. Default is the on-demand price"
}

# On-demand GPU instance
variable "on_demand_gpu_max_cluster_size" {
  type        = string
  description = "Max number of on demand instances in EKS autoscaling group"
  default     = "2"
}

variable "on_demand_gpu_min_cluster_size" {
  type        = string
  description = "Min number of on demand instances in EKS autoscaling group"
  default     = "0"
}

variable "on_demand_gpu_desired_capacity" {
  type        = string
  description = "Desired number of on_demand instances in EKS autoscaling group"
  default     = "0"
}

variable "on_demand_gpu_instance_type" {
  description = "EC2 on_demand Instance type"
  default     = ["p2.xlarge", "g4dn.xlarge", "p3.2xlarge"]
}

variable "on_demand_gpu_allocation_strategy" {
  description = "Strategy to use when launching on-demand instances. Valid values: prioritized"
  default     = "null"
}

variable "on_demand_gpu_base_capacity" {
  description = "Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances"
  default     = "0"

}

variable "on_demand_gpu_percentage_above_base_capacity" {
  description = "Percentage split between on-demand and Spot instances above the base on-demand capacity"
  default     = "0"
}

variable "on_demand_gpu_asg_recreate_on_change" {
  description = "Recreate the autoscaling group when the Launch Template or Launch Configuration change."
  default     = "false"
}

# On-demand CPU instance
variable "on_demand_cpu_max_cluster_size" {
  type        = string
  description = "Max number of on demand instances in EKS autoscaling group"
  default     = "2"
}

variable "on_demand_cpu_min_cluster_size" {
  type        = string
  description = "Min number of on demand instances in EKS autoscaling group"
  default     = "0"
}

variable "on_demand_cpu_desired_capacity" {
  type        = string
  description = "Desired number of on_demand instances in EKS autoscaling group"
  default     = "0"
}

variable "on_demand_cpu_instance_type" {
  description = "EC2 on_demand Instance type"
  default     = ["c5.xlarge", "c5.2xlarge", "c5n.xlarge"]
}

variable "on_demand_cpu_allocation_strategy" {
  description = "Strategy to use when launching on-demand instances. Valid values: prioritized"
  default     = "null"
}

variable "on_demand_cpu_base_capacity" {
  description = "Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances"
  default     = "0"

}

variable "on_demand_cpu_percentage_above_base_capacity" {
  description = "Percentage split between on-demand and Spot instances above the base on-demand capacity"
  default     = "0"
}

variable "on_demand_cpu_asg_recreate_on_change" {
  description = "Recreate the autoscaling group when the Launch Template or Launch Configuration change."
  default     = "false"
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

#Ingress google auth settings
variable "google-auth" {
  description = "Enables Google auth"
  default     = false
}

variable "google-client-id" {
  description = "Client ID for Google auth"
  default     = ""
}

variable "google-client-secret" {
  description = "Client secret for Google auth"
  default     = ""
}

variable "google-cookie-secret" {
  default     = ""
  description = "random_string make gen command python -c 'import os,base64; print base64.b64encode(os.urandom(16))'"
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

variable "efk_oauth2_domain" {
  description = "oauth2 domain for Kibana"
  default     = ""
}

#Jenkins
variable "jenkins_password" {
  description = "Password for jenkins admin"
  default     = "password"
}

variable "agent_policy" {
  description = "Policy attached to Jenkins agents IAM role"
  default     = ""
}

variable "master_policy" {
  description = "Policy attached to Jenkins master IAM role"
  default     = ""
}

#Grafana
variable "grafana_password" {
  description = "Password for grafana admin"
  default     = "password"
}

variable "grafana_google_auth" {
  description = "Enables Google auth for Grafana"
  default     = false
}

variable "grafana_client_id" {
  description = "The id of the client for Grafana Google auth"
  default     = ""
}

variable "grafana_client_secret" {
  description = "The token of the client for Grafana Google auth"
  default     = ""
}

variable "grafana_allowed_domains" {
  description = "Allowed domain for Grafana Google auth"
  default     = ""
}