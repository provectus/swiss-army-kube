module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.6.0"
  cluster_version = var.cluster_version
  cluster_name    = local.cluster_name

  subnet_ids = local.subnets
  vpc_id     = module.vpc.vpc_id

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  enable_irsa                     = true


  #   create_aws_auth_configmap = true
  manage_aws_auth_configmap = true
  aws_auth_roles = var.karpenter_mode == "EKS-MANAGED-NODE-GROUP" ? [] : [
    # We need to add in the Karpenter node IAM role for nodes launched by Karpenter if useing farget profiles
    {
      rolearn  = module.karpenter.role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
    },
  ]

  cluster_enabled_log_types              = var.cloudwatch_logging_enabled ? var.cloudwatch_cluster_log_types : []
  cloudwatch_log_group_retention_in_days = var.cloudwatch_logging_enabled ? var.cloudwatch_cluster_log_retention_days : 90

  node_security_group_enable_recommended_rules = true
  node_security_group_tags = {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = local.cluster_name
  }

  eks_managed_node_groups = {
    initial = {
      name           = "${local.environment}-${local.cluster_name}-initial"
      create         = var.karpenter_mode == "EKS-MANAGED-NODE-GROUP"
      instance_types = ["m5.large"]

      create_security_group   = false
      pre_bootstrap_user_data = "sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm && sudo systemctl enable amazon-ssm-agent && sudo systemctl start amazon-ssm-agent"

      create_iam_role = true
      iam_role_additional_policies = {
        "AmazonSSMManagedInstanceCore" = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
      }

      min_size     = 0
      max_size     = 3
      desired_size = 2

      taints = [{
        "key"    = "CriticalAddonsOnly"
        "value"  = "dedicated"
        "effect" = "NO_SCHEDULE"
      }]
      labels = {
        "CriticalAddonsOnly" = "dedicated"
      }
    }
  }

  tags = {
    Environment = local.environment
    Project     = local.project
  }
  fargate_profiles = {
    karpenter_initial_fargate = {
      name   = "${local.environment}-${local.cluster_name}-karpenter"
      create = var.karpenter_mode == "FARGATE-PROFILE"
      selectors = [
        {
          namespace = "karpenter"
        }
      ]
    }
  }
}