data "aws_ami" "eks_gpu_worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-gpu-node-${var.cluster_version}-*"]
  }

  most_recent = true
  owners      = ["602401143452"] // The ID of the owner of the official AWS EKS AMIs.
}


module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "v12.0.0"
  cluster_version = var.cluster_version
  cluster_name    = var.cluster_name
  kubeconfig_name = var.cluster_name
  subnets         = var.subnets
  vpc_id          = var.vpc_id

  map_users = concat(var.admin_arns, var.user_arns)

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
  worker_groups_launch_template = concat(local.common, local.cpu, local.gpu)
}
