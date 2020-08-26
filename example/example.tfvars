# Name of aws region (us-west-1, us-west-2, us-east-1 etc)
aws_region = "eu-west-3"

# Deploy private mode (Internal route 53, don't use Gateway etc) (true or false)
aws_private = "false"

# List of aws region availability_zones
availability_zones = ["eu-west-3b", "eu-west-3a", "eu-west-3c"]

# Name of kubernetes cluster. It's tag for cluster
cluster_name = "dkharlamov-swiss-army"

# Deploy environment name
environment = "dev"

# Deploy project name
project = "EDUCATION"

#Main route53 zone id if exist (Change It or set empty)
mainzoneid = "Z02149423PVQ0YMP19F13"

# Name of domains (create route53 zone and ingress). Set as array, first main ingress fqdn ["example.com", "example.io"]
domains = ["dkharlamov-swiss-army.edu.provectus.io"]

# The kubernetes config file path
config_path = "kubeconfig_dkharlamov-swiss-army"

# Number would be used to template CIDR 10.X.0.0/16.
network = 10

# ARNs of users which would have admin permissions. (Change It)
admin_arns = [
  {
    userarn  = "arn:aws:iam::245582572290:user/dkharlamov"
    username = "dkharlamov"
    groups   = ["system:masters"]
  },
]

## ARNs of users which would have provided permissions. (Change It)
#user_arns = [
#  {
#    userarn  = "arn:aws:iam::245582572290:user/developer"
#    username = "developer"
#    groups   = ["system:developers"]
#  },
#]

## Cluster role parameters
#cluster_roles = [
#  {
#    cluster_group = "developers"
#    roles         = [
#      {
#        role_resources  = [
#          "deployments",
#          "services",
#          "statefulSets",
#          "ingresses",
#          "namespaces"
#        ]
#        role_verbs      = [
#          "list",
#          "get",
#          "watch"
#        ]
#        role_api_groups = [""]
#      }
#    ]
#  }
#]

#Version of EKS cluster
# Use EKS 1.15 if deploying Kubeflow !!!
cluster_version = "1.16"

# Type and number of worker node
#Common
on_demand_common_max_cluster_size               = "5"
on_demand_common_min_cluster_size               = "1"
on_demand_common_desired_capacity               = "2"
on_demand_common_instance_type                  = ["m5.large"]

#CPU
on_demand_cpu_max_cluster_size               = "2"
on_demand_cpu_min_cluster_size               = "1"
on_demand_cpu_desired_capacity               = "1"
on_demand_cpu_instance_type                  = ["c5.xlarge"]

#GPU
on_demand_gpu_max_cluster_size               = "2"
on_demand_gpu_min_cluster_size               = "1"
on_demand_gpu_desired_capacity               = "1"
on_demand_gpu_instance_type                  = ["p3.2xlarge"]

#Cert-manager (Change It)
cert_manager_email = "dkharlamov@provectus.com"

#Ingress github auth setting (client id and secret in base64 from https://github.com/settings/applications/new )
github-auth          = "false"
github-client-id     = ""
github-client-secret = ""
# random_string make gen command python -c 'import os,base64; print base64.b64encode(os.urandom(16))'
cookie-secret = "1fWkwIpMskU4miQYcCZZUw=="
github-org    = ""

#Ingress google auth settings
google-auth          = "false"
google-client-id     = "xxxxxxx.apps.googleusercontent.com"
google-client-secret = "XXXXXXX"
google-cookie-secret = "1fWkwIpMskU4miQYcCZZUw=="

#Kibana
elasticDataSize = "30Gi"
#Enables oauth2 for Kibana with specified oauth2 domain
#efk_oauth2_domain = "oauth2-google"

#Jenkins (Change It)
jenkins_password = "password"
## Uncomment to attach S3 readonly policy for Jenkins master and agent IAM roles, or customize to add needed policies
#agent_policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Effect": "Allow",
#      "Action": [
#        "s3:Get*",
#        "s3:List*"
#      ],
#      "Resource": "*"
#    }
#  ]
#}
#EOF
#master_policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Effect": "Allow",
#      "Action": [
#        "s3:Get*",
#        "s3:List*"
#      ],
#      "Resource": "*"
#    }
#  ]
#}
#EOF

## To enable Google auth for Grafana just uncomment block below and fill in needed id, secret and allowed domain
#grafana_google_auth     = true
#grafana_client_id       = "xxxxxxx.apps.googleusercontent.com"
#grafana_client_secret   = "XXXXXXX"
#grafana_allowed_domains = "provectus.com"

#RDS
rds_database_name              = "exampledb"
rds_database_engine            = "postgresql" # postgres mysql oracle-ee sqlserver-ex
rds_database_engine_version    = "9.6.9"      #(postgres - 9.6.9, mysql - 5.7.19, oracle-ee - 12.1.0.2.v8, sqlserver-ex - 14.00.1000.169.v1 )
rds_database_instance          = "db.t3.large"
rds_database_username          = "exampleuser"
rds_database_password          = ""
rds_kms_key_id                 = ""
rds_allocated_storage          = "10"
rds_storage_encrypted          = false
rds_maintenance_window         = "Mon:00:00-Mon:03:00"
rds_backup_window              = "03:00-06:00"
rds_database_multi_az          = true
rds_database_delete_protection = false
rds_database_tags              = { "test" = "tags" }
#Airflow
airflow_username = "user"
airflow_password = ""
#about fernetKey https://bcb.github.io/airflow/fernet-key
airflow_fernetKey = "GFqrDfu-0oac6x2ATKLsx-Mr2yHKWFpa5hY4pYeWmXw="
#If use local postgresql, host and port ignore
airflow_postgresql_local    = true
airflow_postgresql_host     = ""
airflow_postgresql_port     = "5432"
airflow_postgresql_username = "postgresqluser"
airflow_postgresql_password = ""
airflow_postgresql_database = "airflow"
#If use local redis, set password and ignore other settings
airflow_redis_local    = true
airflow_redis_host     = ""
airflow_redis_port     = "6379"
airflow_redis_username = "redisuser"
airflow_redis_password = ""
