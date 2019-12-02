# Name of aws region (us-west-1, us-west-2, us-east-1 etc)
region = "us-west-2"

# Name of kubernetes cluster. It's tag for cluster and peace of fqdn domain xxx.<cluster_name>.<domain_name>
cluster_name = "test"

# Name of domain
domain = "hydrosphere.io"

# Number instance for max autoscaling
cluster_size = 2

# Number would be used to template CIDR 10.X.0.0/16.
network = 10

# ARNs of users which would have admin permissions. list(strings)
admin_arns = []

# Instance type to use for running EKS
eks_instance_type = "m5.large"
