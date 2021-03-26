data "aws_ami" "eks_gpu_worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-gpu-node-${var.cluster_version}-*"]
  }

  most_recent = true
  owners      = ["602401143452"] // The ID of the owner of the official AWS EKS AMIs.
}

resource "aws_kms_key" "eks" {
  count = var.enable_secret_encryption ? 1 : 0
  tags  = var.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "v13.2.1"

  wait_for_cluster_interpreter = var.wait_for_cluster_interpreter
  cluster_version              = var.cluster_version
  cluster_name                 = var.cluster_name
  kubeconfig_name              = var.cluster_name
  subnets                      = var.subnets
  vpc_id                       = var.vpc_id
  enable_irsa                  = var.enable_irsa

  map_users = var.aws_auth_user_mapping
  map_roles = var.aws_auth_role_mapping

  tags = local.tags

  cluster_encryption_config = var.enable_secret_encryption ? [
    {
      provider_key_arn = aws_kms_key.eks[0].arn
      resources        = ["secrets"]
    }
  ] : []


  workers_additional_policies = flatten(
    [
      ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"], var.workers_additional_policies
    ]
  )


  workers_group_defaults = {
    additional_userdata = "sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm && sudo systemctl enable amazon-ssm-agent && sudo systemctl start amazon-ssm-agent"
  }

  # Note:
  #   If you add here worker groups with GPUs or some other custom resources make sure
  #   to start the node in ASG manually once or cluster autoscaler doesn't find the resources.
  #
  #   After that autoscaler is able to see the resources on that ASG.
  #
  worker_groups                 = var.worker_groups
  worker_groups_launch_template = var.worker_groups_launch_template
}

# # OIDC cluster EKS settings
# resource "aws_iam_openid_connect_provider" "cluster" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
#   url             = module.eks.cluster_oidc_issuer_url
# }
