# Name of aws region (us-west-1, us-west-2, us-east-1 etc)
aws_region = "us-west-2"

# Deploy private mode (Internal route 53, don't use Gateway etc) (true or false)
aws_private = "false"

# List of aws region availability_zones
availability_zones = ["us-west-2b", "us-west-2a", "us-west-2c"]

# Name of kubernetes cluster. It's tag for cluster
cluster_name = "swiss"

# Deploy environment name
environment = "dev"

# Deploy project name
project = "EDUCATION"

#Main route53 zone id if exist
mainzoneid = "Z02149423PVQ0YMP19F13"

# Name of domains (create route53 zone and ingress). Set as array, first main ingress fqdn ["example.com", "example.io"]
domains = ["swiss-army.edu.provectus.io"]

# The kubernetes config file path
config_path = "kubeconfig_swiss"

# Number would be used to template CIDR 10.X.0.0/16.
network = 10

# ARNs of users which would have admin permissions.
admin_arns = [
  {
    userarn  = "arn:aws:iam::245582572290:user/dkharlamov"
    username = "dkharlamov"
    groups   = ["system:masters"]
  },
]

# Type and number of worker node
on_demand_max_cluster_size = "2"
on_demand_min_cluster_size = "2"
on_demand_desired_capacity = "2"
on_demand_instance_type    = "m5.large"
spot_max_cluster_size      = "2"
spot_min_cluster_size      = "0"
spot_desired_capacity      = "0"
spot_instance_type         = "m5.large"
cluster_version            = "1.15"

#Cert-manager
cert_manager_email = "dkharlamov@provectus.com"

#Ingress github auth setting (client id and secret in base64 from https://github.com/settings/applications/new )
github-auth          = "false"
github-client-id     = ""
github-client-secret = ""
# random_string make gen command python -c 'import os,base64; print base64.b64encode(os.urandom(16))'
cookie-secret = "1fWkwIpMskU4miQYcCZZUw=="
github-org    = ""

#Kibana
elasticDataSize = "30Gi"

#Jenkins
jenkins_password = "password"

#Grafana
grafana_password = "password"
