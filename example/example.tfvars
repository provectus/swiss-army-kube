# Name of aws region (us-west-1, us-west-2, us-east-1 etc)
aws_region = "us-west-2"

# List of aws region availability_zones
availability_zones = ["us-west-2b", "us-west-2a", "us-west-2c"]

# Name of kubernetes cluster. It's tag for cluster and peace of fqdn domain xxx.<cluster_name>.<domain_name>
cluster_name = "poc"

# Deploy environment name
environment = "dev"

# Deploy project name
project = "EDUCATION"

# Name of domain
domain = "test.hydrosphere.io"

# The kubernetes config file path
config_path = "kubeconfig_poc"

# Number would be used to template CIDR 10.X.0.0/16.
network = 10

# ARNs of users which would have admin permissions. list(strings)
admin_arns = []

# Type and number of worker node
on_demand_max_cluster_size = "3"
on_demand_desired_capacity = "3"
on_demand_instance_type    = "m5.large"
spot_max_cluster_size      = "6"
spot_desired_capacity      = "2"
spot_instance_type         = "m5.large"
cluster_version            = "1.14"

#Cert-manager
cert_manager_email  = "dkharlamov@provectus.com"
cert_manager_zoneid = "ZYMN6BWSD7TUV"

#Ingress github auth setting
github-auth          = "false"
github-client-id     = ""
github-client-secret = ""
cookie-secret        = "1fWkwIpMskU4miQYcCZZUw=="