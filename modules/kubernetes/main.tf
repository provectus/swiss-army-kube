data "aws_ami" "eks_gpu_worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-gpu-node-${var.cluster_version}-*"]
  }

  most_recent = true
  owners      = ["602401143452"] // The ID of the owner of the official AWS EKS AMIs.
}

resource "aws_iam_role" "asg-common" {
  name = "${var.cluster_name}-node-group-common"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.asg-common.name
}

resource "aws_iam_role_policy_attachment" "AmazonRoute53AutoNamingFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53AutoNamingFullAccess"
  role       = aws_iam_role.asg-common.name
}

resource "aws_iam_role_policy_attachment" "AmazonElasticFileSystemFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
  role       = aws_iam_role.asg-common.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.asg-common.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.asg-common.name
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.asg-common.name
}

resource "aws_iam_role_policy_attachment" "ElasticLoadBalancingFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
  role       = aws_iam_role.asg-common.name
}

resource "aws_iam_role_policy_attachment" "AmazonRoute53FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
  role       = aws_iam_role.asg-common.name
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "v12.0.0"
  cluster_version = var.cluster_version
  cluster_name    = var.cluster_name
  kubeconfig_name = var.cluster_name
  subnets         = var.subnets
  vpc_id          = var.vpc_id
  #Map roles for worker node has access to master node
  map_roles = [
    {
      rolearn  = aws_iam_role.asg-common.arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
  ]
  map_users = concat(var.admin_arns, var.user_arns)

  tags = {
    Environment = var.environment
    Project     = var.project
  }

  #TODO:

  # node_group_defaults = {
  #   additional_userdata = "sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm && sudo systemctl enable amazon-ssm-agent && sudo systemctl start amazon-ssm-agent"
  # }


  # Note:
  #   If you add here worker groups with GPUs or some other custom resources make sure
  #   to start the node in ASG manually once or cluster autoscaler doesn't find the resources.
  #
  #   After that autoscaler is able to see the resources on that ASG.
}

#NODE GROUPS
resource "aws_eks_node_group" "common_node_group" {
  depends_on = [
    module.eks.cluster_id
  ]
  count           = var.on_demand_common_enabled ? 1 : 0
  ami_type        = "AL2_x86_64"
  cluster_name    = var.cluster_name
  disk_size       = 100
  instance_types  = var.on_demand_common_instance_type
  labels          = {
    "node-type" = "common"
  }
  node_group_name = "${var.cluster_name}-autoscaling-common"
  node_role_arn   = aws_iam_role.asg-common.arn
  subnet_ids      = var.subnets
  tags = {
    "Environment"                                             = var.environment
    "Project"                                                 = var.project
    "Name"                                                    = "${var.cluster_name}-eks-ondemand-common"
    "k8s.io/cluster-autoscaler/enabled"                       = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}"           = "owned"
    "k8s.io/cluster-autoscaler/node-template/label/node-type" = "common"

  }
  scaling_config {
    desired_size = var.on_demand_common_desired_capacity
    max_size     = var.on_demand_common_max_cluster_size
    min_size     = var.on_demand_common_min_cluster_size
  }
  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

}

resource "aws_eks_node_group" "cpu_node_group" {
  depends_on = [
    module.eks.cluster_id
  ]
  count           = var.on_demand_cpu_enabled ? 1 : 0
  ami_type        = "AL2_x86_64"
  cluster_name    = var.cluster_name
  disk_size       = 100
  instance_types  = var.on_demand_cpu_instance_type
  labels          = {
    "node-type" = "cpu"    
  }
  node_group_name = "${var.cluster_name}-autoscaling-cpu"
  node_role_arn   = aws_iam_role.asg-common.arn
  subnet_ids      = var.subnets
  tags = {
    "Environment"                                             = var.environment
    "Project"                                                 = var.project
    "Name"                                                    = "${var.cluster_name}-eks-ondemand-cpu"
    "k8s.io/cluster-autoscaler/enabled"                       = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}"           = "owned"
    "k8s.io/cluster-autoscaler/node-template/label/node-type" = "cpu"
    "k8s.io/cluster-autoscaler/node-template/taint/node-type" = "cpu:NoSchedule"
  }
  scaling_config {
    desired_size = var.on_demand_cpu_desired_capacity
    max_size     = var.on_demand_cpu_max_cluster_size
    min_size     = var.on_demand_cpu_min_cluster_size
  }
  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

resource "aws_eks_node_group" "gpu_node_group" {
  depends_on = [
    module.eks.cluster_id
  ]  
  count           = var.on_demand_gpu_enabled ? 1 : 0
  ami_type        = "AL2_x86_64_GPU"
  cluster_name    = var.cluster_name
  disk_size       = 100
  instance_types  = var.on_demand_gpu_instance_type
  labels          = {
    "node-type"          = "gpu"
    "nvidia.com/gpu"     = "gpu"    
  }
  node_group_name = "${var.cluster_name}-autoscaling-gpu"
  node_role_arn   = aws_iam_role.asg-common.arn
  subnet_ids      = var.subnets
  tags = {
    "Environment"                                                      = var.environment
    "Project"                                                          = var.project
    "Name"                                                             = "${var.cluster_name}-eks-ondemand-gpu"    
    "k8s.io/cluster-autoscaler/enabled"                                = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}"                    = "owned"
    "k8s.io/cluster-autoscaler/node-template/label/node-type"          = "gpu"
    "k8s.io/cluster-autoscaler/node-template/label/nvidia.com/gpu"     = "gpu"
    "k8s.io/cluster-autoscaler/node-template/taint/node-type"          = "gpu:NoSchedule"
    "k8s.io/cluster-autoscaler/node-template/taint/nvidia.com/gpu"     = "gpu:NoSchedule"
    "k8s.io/cluster-autoscaler/node-template/resources/nvidia.com/gpu" = "1" # Change to the number of GPUs on your node type
  }
  scaling_config {
    desired_size = var.on_demand_gpu_desired_capacity
    max_size     = var.on_demand_gpu_max_cluster_size
    min_size     = var.on_demand_gpu_min_cluster_size
  }
  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}
