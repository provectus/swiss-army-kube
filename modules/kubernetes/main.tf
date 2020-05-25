module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "v12.0.0"
  cluster_version = var.cluster_version
  cluster_name    = var.cluster_name
  subnets         = var.subnets
  vpc_id          = var.vpc_id

  map_users = var.admin_arns

  tags = {
    Environment = var.environment
    Project     = var.project
  }

  workers_additional_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53AutoNamingFullAccess",
    "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
  ]

  workers_group_defaults = {
     additional_userdata = "sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm && sudo systemctl enable amazon-ssm-agent && sudo systemctl start amazon-ssm-agent"
  }

  # Note:
  #   If you add here worker groups with GPUs or some other custom resources make sure 
  #   to start the node in ASG manually once or cluster autoscaler doesn't find the resources.
  #
  #   After that autoscaler is able to see the resources on that ASG.
  #
  worker_groups = [
    {
      name                 = "on-demand-1"
      instance_type        = var.on_demand_instance_type
      asg_max_size         = var.on_demand_max_cluster_size
      asg_min_size         = var.on_demand_min_cluster_size
      asg_desired_capacity = var.on_demand_desired_capacity
      autoscaling_enabled  = false
      kubelet_extra_args   = "--node-labels=node.kubernetes.io/lifecycle=normal"
      suspended_processes  = ["AZRebalance"]
    },
    {
      name                 = "spot-1"
      spot_price           = var.spot_price
      instance_type        = var.spot_instance_type
      asg_max_size         = var.spot_max_cluster_size
      asg_min_size         = var.spot_min_cluster_size
      asg_desired_capacity = var.spot_desired_capacity
      autoscaling_enabled  = true
      kubelet_extra_args   = "--node-labels=node.kubernetes.io/lifecycle=spot"
      suspended_processes  = ["AZRebalance"]
    }
  ]
}
