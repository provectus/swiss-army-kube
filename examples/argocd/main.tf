data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v2.64.0"

  name = "${local.environment}-${local.cluster_name}"

  cidr = local.cidr

  azs             = local.zones
  private_subnets = local.private
  public_subnets  = local.public

  enable_nat_gateway = true
  single_nat_gateway = var.single_nat

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    Name                                          = "${local.environment}-${local.cluster_name}-public"
    KubernetesCluster                             = local.cluster_name
    Environment                                   = local.environment
    Project                                       = local.project
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    Name                                          = "${local.environment}-${local.cluster_name}-private"
    "kubernetes.io/role/elb-internal"             = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }

  tags = {
    Name        = "${local.environment}-${local.cluster_name}"
    Environment = local.environment
    Project     = local.project
    Terraform   = "true"
  }
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.30.2"

  cluster_version = var.cluster_version
  cluster_name    = local.cluster_name

  prefix_separator                   = ""
  iam_role_name                      = local.cluster_name
  cluster_security_group_name        = local.cluster_name
  cluster_security_group_description = "EKS cluster security group."

  subnet_ids  = local.subnets
  vpc_id      = module.vpc.vpc_id
  enable_irsa = false

  manage_aws_auth_configmap = true
  create_aws_auth_configmap = true
  # NOTE:
  #  enable cloudwatch logging
  cluster_enabled_log_types              = var.cloudwatch_logging_enabled ? var.cloudwatch_cluster_log_types : []
  cloudwatch_log_group_retention_in_days = var.cloudwatch_logging_enabled ? var.cloudwatch_cluster_log_retention_days : 90

  self_managed_node_group_defaults = {
    update_launch_template_default_version = true
    iam_role_additional_policies = [
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
      "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
      "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
      "arn:aws:iam::aws:policy/AmazonRoute53AutoNamingFullAccess",
      "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess",
      "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    ]
    additional_userdata  = "sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm && sudo systemctl enable amazon-ssm-agent && sudo systemctl start amazon-ssm-agent"
    bootstrap_extra_args = local.default_bootstrap_extra_args
    metadata_options = {
      http_endpoint = "enabled"
      http_tokens   = "optional"
    }
  }

  # Note:
  #   If you add here worker groups with GPUs or some other custom resources make sure
  #   to start the node in ASG manually once or cluster autoscaler doesn't find the resources.
  #
  #   After that autoscaler is able to see the resources on that ASG.
  #
  self_managed_node_groups = {
    general = {
      # expected length of name to be in the range (1 - 38)
      name         = "${local.environment}-${local.cluster_name}"
      max_size     = 3
      desired_size = 1

      bootstrap_extra_args = "${local.default_bootstrap_extra_args} --kubelet-extra-args \"--node-labels=node-type=general,node.kubernetes.io/lifecycle=`curl -s http://169.254.169.254/latest/meta-data/instance-life-cycle`\""

      use_mixed_instances_policy = true
      mixed_instances_policy = {
        instances_distribution = {
          on_demand_base_capacity                  = 0
          on_demand_percentage_above_base_capacity = 10
          spot_allocation_strategy                 = "capacity-optimized"
        }

        override = [
          {
            instance_type     = "m5.large"
            weighted_capacity = "1"
          },
          {
            instance_type     = "m6i.large"
            weighted_capacity = "2"
          },
        ]
      }
    }
    # worker_group = concat(local.common, local.cpu, local.gpu)
  }
}
# OIDC cluster EKS settings
resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  url             = module.eks.cluster_oidc_issuer_url
}


module "argocd" {
  depends_on = [module.vpc.vpc_id, module.eks.cluster_id, data.aws_eks_cluster.cluster]
  source     = "github.com/provectus/sak-argocd"

  branch       = var.argocd.branch
  owner        = var.argocd.owner
  repository   = var.argocd.repository
  cluster_name = module.eks.cluster_id
  path_prefix  = "examples/argocd/"

  domains = local.domain
  ingress_annotations = {
    "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
  }
  conf = {
    "server.service.type"     = "ClusterIP"
    "server.ingress.paths[0]" = "/"
  }
}
