data "aws_eks_cluster" "cluster" {
  name = module.kubernetes.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.kubernetes.cluster_name
}

locals {
  environment  = var.environment
  project      = var.project
  cluster_name = var.cluster_name
  tags = {
    environment = local.environment
    project     = local.project
  }
}

module "network" {
  source = "github.com/provectus/sak-vpc"

  availability_zones = var.availability_zones
  environment        = local.environment
  project            = local.project
  cluster_name       = local.cluster_name
  network            = 10
}

module "kubernetes" {
  depends_on = [module.network]
  source = "github.com/provectus/sak-kubernetes"

  environment        = local.environment
  project            = local.project
  availability_zones = var.availability_zones
  cluster_name       = local.cluster_name
  cluster_version    = "1.18"
  vpc_id             = module.network.vpc_id
  subnets            = module.network.private_subnets
  admin_arns = [
    {
      userarn  = "arn:aws:iam::xxxxxxxx:user/username"
      username = "username"
      groups   = ["system:masters"]
    }
  ]
  user_arns = []
  #[
  #  {
  #    userarn  = "arn:aws:iam::xxxxxxx:user/developer"
  #    username = "developer"
  #    groups   = ["system:developers"]
  #  },
  #]
  #On-demand
  on_demand_common_max_cluster_size = 5
  on_demand_common_min_cluster_size = 1
  on_demand_common_desired_capacity = 1
  on_demand_common_instance_type    = "m5.large"

  #CPU
  on_demand_cpu_max_cluster_size = 0
  on_demand_cpu_min_cluster_size = 0
  on_demand_cpu_desired_capacity = 0
  #GPU
  on_demand_gpu_max_cluster_size = 0
  on_demand_gpu_min_cluster_size = 0
  on_demand_gpu_desired_capacity = 0

  on_demand_gpu_instance_type = "g4dn.xlarge"
}

module "system" {
  depends_on = [module.network.vpc_id, module.kubernetes.cluster_name]
  source            = "../../modules/system"

  environment        = local.environment
  project            = local.project
  cluster_name       = module.kubernetes.cluster_name
  vpc_id             = module.network.vpc_id
  aws_private        = false
  domains            = ["${var.cluster_name}.${var.domains[0]}"]
  config_path        = "kubeconfig_${var.cluster_name}"
  mainzoneid         = var.mainzoneid
  cert_manager_email = var.cert_manager_email
  cluster_oidc_url   = module.kubernetes.cluster_oidc_url
  cluster_oidc_arn   = module.kubernetes.oidc_provider_arn
  cluster_roles      = []
}
#
# module "scaling" {
#   module_depends_on = [module.system.cert-manager]
#   source            = "../../modules/scaling"
#   cluster_name      = module.kubernetes.cluster_name
# }

# module "scaling" {
#   module_depends_on = [module.system.cert-manager]
#   source            = "../../modules/scaling"
#   cluster_name      = module.kubernetes.cluster_name
# }

# module "acm" {
#   source  = "terraform-aws-modules/acm/aws"
#   version = "v2.0"

#  domain_name               = "${var.cluster_name}.edu.provectus.io"
#  subject_alternative_names = ["*.${var.cluster_name}.edu.provectus.io"]
#  zone_id                   = module.system.route53_zone[0].zone_id
#  validate_certificate      = false
#  tags                      = local.tags
# }

# module "nginx" {
#   module_depends_on = [module.system.cert-manager]
#   source            = "../../modules/ingress/nginx"

#   cluster_name = module.kubernetes.cluster_name
#   aws_private  = "false"
#   domains      = ["swiss-army.example.io"]

#   #Need oauth2-proxy github auth? Use id and secret in base64
#   github-auth          = "false"
#   github-client-id     = "<github-client-id>"
#   github-org           = "<github-org>"
#   github-client-secret = "<github-client-secret>"
#   cookie-secret        = "<cookie-secret>"

#   #Settings for oauth2-proxy google auth
#   google-auth          = "false"
#   google-client-id     = "<google-client-id>"
#   google-client-secret = "<google-client-secret>"
#   google-cookie-secret = "<google-cookie-secret>"
# }

# module "alb-ingress" {
#   module_depends_on = [module.system.cert-manager]
#   source            = "../../modules/ingress/alb-ingress"
#   cluster_name      = module.kubernetes.cluster_name
#   domains           = ["swiss-army.example.io"]
#   vpc_id            = module.network.vpc_id
#   aws_region        = "us-west-2"
#   certificates_arns = [module.acm.this_acm_certificate_arn]
#   cluster_oidc_url  = module.kubernetes.cluster_oidc_url
# }

# module "argo" {
#   module_depends_on = [module.system.cluster_available]
#   source            = "../../modules/cicd/argo"
#   cluster_name      = module.kubernetes.cluster_name
#   domains           = ["swiss-army.example.io"]
#   environment       = local.environment
#   project           = local.project
#   cluster_oidc_url  = module.kubernetes.cluster_oidc_url
# }


# module "jenkins" {
#   module_depends_on = [module.system.cert-manager, module.nginx.nginx-ingress]
#   source            = "../../modules/cicd/jenkins"

#   domains          = ["swiss-army.example.io"]
#   jenkins_password = "<jenkins_password>"

#   environment      = local.environment
#   project          = local.project
#   cluster_name     = module.kubernetes.cluster_name
#   cluster_oidc_url = module.kubernetes.cluster_oidc_url
#   cluster_oidc_arn = module.system.oidc_arn

#   master_policy = "<master_policy>"
#   agent_policy  = "<agent_policy>"
# }

# module "prometheus" {
#  module_depends_on       = [module.system.cert-manager, module.nginx.nginx-ingress]
#  source                  = "../../modules/monitoring/prometheus"
#
#  cluster_name            = module.kubernetes.cluster_name
#  domains                 = ["swiss-army.example.io"]
#  grafana_google_auth     = "<grafana_google_auth>"
#  grafana_client_id       = "<grafana_client_id>"
#  grafana_client_secret   = "<grafana_client_secret>"
#  grafana_allowed_domains = "<grafana_allowed_domains>"
# }

# module "loki" {
#  module_depends_on = [module.system.cert-manager,module.nginx.nginx-ingress]
#  source            = "../../modules/logging/loki"
#
#  cluster_name = module.kubernetes.cluster_name
#  domains      = ["swiss-army.example.io"]
# }

# module "efk" {
#  module_depends_on     = [module.system.cert-manager,module.nginx.nginx-ingress]
#  source                = "../../modules/logging/efk"
#  domains               = ["swiss-army.example.io"]
#  elasticsearch-curator = "<elasticsearch-curator>"
#  logstash              = "<logstash>"
#  filebeat              = "<filebeat>"
#  success_limit         = "<success_limit>"
#  failed_limit          = "<failed_limit>"
#  elasticDataSize       = "<elasticDataSize>"
#  efk_oauth2_domain     = "<efk_oauth2_domain>"
# }

# module "rds" {
#  module_depends_on = [module.network.vpc_id, module.kubernetes.cluster_name, module.kubernetes.workers_launch_template_ids]
#  source            = "../../modules/rds"

#  environment  = local.environment
#  project      = local.project
#  cluster_name = module.kubernetes.cluster_name
#  subnets                             = module.network.private_subnets
#  rds_database_name                   = "<rds_database_name>"
#  rds_database_username               = "<rds_database_username>"
#  rds_database_password               = "<rds_database_password>"
#  rds_database_engine                 = "<rds_database_engine>"
#  rds_database_engine_version         = "<rds_database_engine_version>"
#  rds_database_major_engine_version   = "<rds_database_major_engine_version>"
#  rds_database_instance               = "<rds_database_instance>"
#  rds_database_multi_az               = "<rds_database_multi_az>"
#  rds_database_delete_protection      = "<rds_database_delete_protection>"
#  rds_allocated_storage               = "<rds_allocated_storage>"
#  rds_storage_encrypted               = "<rds_storage_encrypted>"
#  rds_kms_key_id                      = "<rds_kms_key_id>"
#  rds_maintenance_window              = "<rds_maintenance_window>"
#  rds_backup_window                   = "<rds_backup_window>"
#  rds_database_tags                   = "<rds_database_tags>"
#  vpc_id                              = module.network.vpc_id
# }

# module "airflow" {
#  module_depends_on = [module.system.cert-manager, module.nginx.nginx-ingress]
#  source            = "../../modules/airflow"
#
#  cluster_name                = module.kubernetes.cluster_name
#  domains                     = ["swiss-army.example.io"]
#  airflow_password            = "<airflow_password>"
#  airflow_username            = "<airflow_username>"
#  airflow_fernetKey           = "<airflow_fernetKey>"
#  airflow_postgresql_local    = "<airflow_postgresql_local>"
#  airflow_postgresql_host     = "<airflow_postgresql_host>"
#  airflow_postgresql_port     = "<airflow_postgresql_port>"
#  airflow_postgresql_username = "<airflow_postgresql_username>"
#  airflow_postgresql_password = "<airflow_postgresql_password>"
#  airflow_postgresql_database = "<airflow_postgresql_database>"
#  airflow_redis_local         = "<airflow_redis_local>"
#  airflow_redis_host          = "<airflow_redis_host>"
#  airflow_redis_port          = "<airflow_redis_port>"
#  airflow_redis_username      = "<airflow_redis_username>"
#  airflow_redis_password      = "<airflow_redis_password>"
# }
