module "network" {
  source = "../modules/network"

  availability_zones = var.availability_zones
  environment        = var.environment
  project            = var.project
  cluster_name       = var.cluster_name
  network            = var.network
}

# module "acm" {
#   source  = "terraform-aws-modules/acm/aws"
#   version = "~> v2.0"

#   domain_name               = var.domains[0]
#   subject_alternative_names = ["*.${var.domains[0]}"]
#   zone_id                   = module.system.route53_zone[0].zone_id
#   validate_certificate      = var.aws_private == "false" ? true : false
#   tags                      = local.tags
# }

module "kubernetes" {
  source = "../modules/kubernetes"

  environment        = var.environment
  project            = var.project
  availability_zones = var.availability_zones
  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  vpc_id             = module.network.vpc_id
  subnets            = module.network.private_subnets
  admin_arns         = var.admin_arns
  user_arns          = var.user_arns
  #On-demand
  on_demand_common_max_cluster_size               = var.on_demand_common_max_cluster_size
  on_demand_common_min_cluster_size               = var.on_demand_common_min_cluster_size
  on_demand_common_desired_capacity               = var.on_demand_common_desired_capacity
  on_demand_common_instance_type                  = var.on_demand_common_instance_type
  on_demand_common_allocation_strategy            = var.on_demand_common_allocation_strategy
  on_demand_common_base_capacity                  = var.on_demand_common_base_capacity
  on_demand_common_percentage_above_base_capacity = var.on_demand_common_percentage_above_base_capacity
  on_demand_common_asg_recreate_on_change         = var.on_demand_common_asg_recreate_on_change
  #Spot
  spot_max_cluster_size       = var.spot_max_cluster_size
  spot_min_cluster_size       = var.spot_min_cluster_size
  spot_desired_capacity       = var.spot_desired_capacity
  spot_instance_type          = var.spot_instance_type
  spot_instance_pools         = var.spot_instance_pools
  spot_asg_recreate_on_change = var.spot_asg_recreate_on_change
  spot_allocation_strategy    = var.spot_allocation_strategy
  spot_max_price              = var.spot_max_price
  #CPU
  on_demand_cpu_max_cluster_size               = var.on_demand_cpu_max_cluster_size
  on_demand_cpu_min_cluster_size               = var.on_demand_cpu_min_cluster_size
  on_demand_cpu_desired_capacity               = var.on_demand_cpu_desired_capacity
  on_demand_cpu_instance_type                  = var.on_demand_cpu_instance_type
  on_demand_cpu_allocation_strategy            = var.on_demand_cpu_allocation_strategy
  on_demand_cpu_base_capacity                  = var.on_demand_cpu_base_capacity
  on_demand_cpu_percentage_above_base_capacity = var.on_demand_cpu_percentage_above_base_capacity
  on_demand_cpu_asg_recreate_on_change         = var.on_demand_cpu_asg_recreate_on_change
  #GPU
  on_demand_gpu_max_cluster_size               = var.on_demand_gpu_max_cluster_size
  on_demand_gpu_min_cluster_size               = var.on_demand_gpu_min_cluster_size
  on_demand_gpu_desired_capacity               = var.on_demand_gpu_desired_capacity
  on_demand_gpu_instance_type                  = var.on_demand_gpu_instance_type
  on_demand_gpu_allocation_strategy            = var.on_demand_gpu_allocation_strategy
  on_demand_gpu_base_capacity                  = var.on_demand_gpu_base_capacity
  on_demand_gpu_percentage_above_base_capacity = var.on_demand_gpu_percentage_above_base_capacity
  on_demand_gpu_asg_recreate_on_change         = var.on_demand_gpu_asg_recreate_on_change
}

# module "system" {
#   module_depends_on = [module.network.vpc_id, module.kubernetes.cluster_name, module.kubernetes.workers_launch_template_ids]
#   source            = "../modules/system"

#   environment        = var.environment
#   project            = var.project
#   cluster_name       = var.cluster_name
#   vpc_id             = module.network.vpc_id
#   aws_private        = var.aws_private
#   domains            = var.domains
#   mainzoneid         = var.mainzoneid
#   config_path        = "${path.module}/kubeconfig_${var.cluster_name}"
#   cert_manager_email = var.cert_manager_email
#   cluster_oidc_url   = module.kubernetes.cluster_oidc_url
#   cluster_roles      = var.cluster_roles
# }

# module "scaling" {
#   module_depends_on = [module.system.cert-manager]
#   source            = "../modules/scaling"
#   cluster_name      = module.kubernetes.cluster_name
# }

# Ingress
# module "nginx" {
#   module_depends_on = [module.system.cert-manager]
#   source            = "../modules/ingress/nginx"

#   cluster_name = var.cluster_name
#   aws_private  = var.aws_private
#   domains      = var.domains
#   config_path  = "${path.module}/kubeconfig_${var.cluster_name}"

#   #Need oauth2-proxy github auth? Use id and secret in base64
#   github-auth          = var.github-auth
#   github-client-id     = var.github-client-id
#   github-org           = var.github-org
#   github-client-secret = var.github-client-secret
#   cookie-secret        = var.cookie-secret

#   #Settings for oauth2-proxy google auth
#   google-auth          = var.google-auth
#   google-client-id     = var.google-client-id
#   google-client-secret = var.google-client-secret
#   google-cookie-secret = var.google-cookie-secret
# }

# module "alb-ingress" {
#   module_depends_on = [module.system.cert-manager]
#   source            = "../modules/ingress/aws-alb"
#   cluster_name      = module.kubernetes.cluster_name
#   domains           = var.domains
#   vpc_id            = module.network.vpc_id
#   certificates_arns = [module.acm.this_acm_certificate_arn]
# }

# # Argoproj: all-in-one
# module "argo" {
#   module_depends_on = [module.system.cluster_available]
#   source            = "../modules/cicd/argo"
#   cluster_name      = var.cluster_name
#   domains           = var.domains
#   environment       = var.environment
#   project           = var.project
#   cluster_oidc_url  = module.kubernetes.cluster_oidc_url
# }

## Kubeflow
## Use EKS 1.15 in terraform.tfvars if deploying Kubeflow !!!
## Enable module efs and argo
#module "kubeflow" {
#  module_depends_on = [module.system.cert-manager, module.argo]
#  source            = "../modules/kubeflow"
#  vpc               = module.network.vpc
#  cluster_name      = module.kubernetes.cluster_name
#  cluster           = module.kubernetes.this
#  artifacts         = module.argo.artifacts
#  config_path       = "${path.module}/kubeconfig_${var.cluster_name}"
#}

#module "efs" {
#  module_depends_on = [module.system.cert-manager]
#  source            = "../modules/storage/efs"
#  vpc               = module.network.vpc
#  cluster_name      = module.kubernetes.cluster_name
#}

# Jenkins
# module "jenkins" {
#   module_depends_on = [module.system.cert-manager, module.nginx.nginx-ingress]
#   source            = "../modules/cicd/jenkins"

#   domains          = var.domains
#   jenkins_password = var.jenkins_password

#   environment      = var.environment
#   project          = var.project
#   cluster_name     = var.cluster_name
#   cluster_oidc_url = module.kubernetes.cluster_oidc_url
#   cluster_oidc_arn = module.system.oidc_arn

#   master_policy = var.master_policy
#   agent_policy  = var.agent_policy

#   config_path = "${path.module}/kubeconfig_${var.cluster_name}"
# }

## Monitoring
#module "prometheus" {
#  module_depends_on       = [module.system.cert-manager, module.nginx.nginx-ingress]
#  source                  = "../modules/monitoring/prometheus"
#
#  cluster_name            = var.cluster_name
#  domains                 = var.domains
#  grafana_google_auth     = var.grafana_google_auth
#  grafana_client_id       = var.grafana_client_id
#  grafana_client_secret   = var.grafana_client_secret
#  grafana_allowed_domains = var.grafana_allowed_domains
#  config_path             = "${path.module}/kubeconfig_${var.cluster_name}"
#}

## Logging
#module "loki" {
#  module_depends_on = [module.system.cert-manager,module.nginx.nginx-ingress]
#  source            = "../modules/logging/loki"
#
#  cluster_name = var.cluster_name
#  domains      = var.domains
#  config_path  = "${path.module}/kubeconfig_${var.cluster_name}"
#}

#module "efk" {
#  module_depends_on     = [module.system.cert-manager,module.nginx.nginx-ingress]
#  source                = "../modules/logging/efk"
#  domains               = var.domains
#  config_path           = "${path.module}/kubeconfig_${var.cluster_name}"
#  elasticsearch-curator = var.elasticsearch-curator
#  logstash              = var.logstash
#  filebeat              = var.filebeat
#  success_limit         = var.success_limit
#  failed_limit          = var.failed_limit
#  elasticDataSize       = var.elasticDataSize
#  efk_oauth2_domain     = var.efk_oauth2_domain
#}

#RDS
# module "rds" {
#  module_depends_on = [module.network.vpc_id, module.kubernetes.cluster_name, module.kubernetes.workers_launch_template_ids]
#  source            = "../modules/rds"

#  environment  = var.environment
#  project      = var.project
#  cluster_name = module.kubernetes.cluster_name
#  subnets                             = module.network.private_subnets
#  rds_database_name                   = var.rds_database_name
#  rds_database_username               = var.rds_database_username
#  rds_database_password               = var.rds_database_password
#  rds_database_engine                 = var.rds_database_engine
#  rds_database_engine_version         = var.rds_database_engine_version
#  rds_database_major_engine_version   = var.rds_database_major_engine_version
#  rds_database_instance               = var.rds_database_instance
#  rds_database_multi_az               = var.rds_database_multi_az
#  rds_database_delete_protection      = var.rds_database_delete_protection
#  rds_allocated_storage               = var.rds_allocated_storage
#  rds_storage_encrypted               = var.rds_storage_encrypted
#  rds_kms_key_id                      = var.rds_kms_key_id
#  rds_maintenance_window              = var.rds_maintenance_window
#  rds_backup_window                   = var.rds_backup_window
#  rds_database_tags                   = var.rds_database_tags
#  vpc_id                              = module.network.vpc_id

#  config_path = "${path.module}/kubeconfig_${var.cluster_name}"
# }

#Airflow
#module "airflow" {
#  module_depends_on = [module.system.cert-manager, module.nginx.nginx-ingress]
#  source            = "../modules/airflow"
#
#  cluster_name                = var.cluster_name
#  domains                     = var.domains
#  airflow_password            = var.airflow_password
#  airflow_username            = var.airflow_username
#  airflow_fernetKey           = var.airflow_fernetKey
#  airflow_postgresql_local    = var.airflow_postgresql_local
#  airflow_postgresql_host     = var.airflow_postgresql_host
#  airflow_postgresql_port     = var.airflow_postgresql_port
#  airflow_postgresql_username = var.airflow_postgresql_username
#  airflow_postgresql_password = var.airflow_postgresql_password
#  airflow_postgresql_database = var.airflow_postgresql_database
#  airflow_redis_local         = var.airflow_redis_local
#  airflow_redis_host          = var.airflow_redis_host
#  airflow_redis_port          = var.airflow_redis_port
#  airflow_redis_username      = var.airflow_redis_username
#  airflow_redis_password      = var.airflow_redis_password
#
#  config_path = "${path.module}/kubeconfig_${var.cluster_name}"
#}
