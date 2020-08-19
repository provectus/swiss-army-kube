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
  worker_groups_launch_template = [
    {
      name                                     = "on-demand-common-1"
      override_instance_types                  = var.on_demand_common_instance_type
      asg_max_size                             = var.on_demand_common_max_cluster_size
      asg_min_size                             = var.on_demand_common_min_cluster_size
      asg_desired_capacity                     = var.on_demand_common_desired_capacity
      asg_recreate_on_change                   = var.on_demand_common_asg_recreate_on_change
      on_demand_allocation_strategy            = var.on_demand_common_allocation_strategy
      on_demand_base_capacity                  = var.on_demand_common_base_capacity
      on_demand_percentage_above_base_capacity = var.on_demand_common_percentage_above_base_capacity
      autoscaling_enabled                      = false
      kubelet_extra_args                       = "--node-labels=node.kubernetes.io/lifecycle=normal,node-type=common"
      suspended_processes                      = ["AZRebalance"]
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/label/node-type"
          "propagate_at_launch" = "false"
          "value"               = "common"
        }
      ]
    },
    {
      name                     = "spot-1"
      spot_max_price           = var.spot_max_price
      override_instance_types  = var.spot_instance_type
      spot_instance_pools      = var.spot_instance_pools
      spot_allocation_strategy = var.spot_allocation_strategy
      spot_instance_pools      = var.spot_instance_pools
      asg_max_size             = var.spot_max_cluster_size
      asg_min_size             = var.spot_min_cluster_size
      asg_desired_capacity     = var.spot_desired_capacity
      asg_recreate_on_change   = var.spot_asg_recreate_on_change
      autoscaling_enabled      = true
      kubelet_extra_args       = "--node-labels=node.kubernetes.io/lifecycle=spot,node-type=spot --register-with-taints=node-type=spot:NoSchedule"
      suspended_processes      = ["AZRebalance"]
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/label/node-type"
          "propagate_at_launch" = "false"
          "value"               = "spot"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/taint/node-type"
          "propagate_at_launch" = "false"
          "value"               = "spot:NoSchedule"
        }
      ]
    },
    {
      name                                     = "on-demand-cpu-1"
      override_instance_types                  = var.on_demand_cpu_instance_type
      asg_max_size                             = var.on_demand_cpu_max_cluster_size
      asg_min_size                             = var.on_demand_cpu_min_cluster_size
      asg_desired_capacity                     = var.on_demand_cpu_desired_capacity
      asg_recreate_on_change                   = var.on_demand_cpu_asg_recreate_on_change
      on_demand_allocation_strategy            = var.on_demand_cpu_allocation_strategy
      on_demand_base_capacity                  = var.on_demand_cpu_base_capacity
      on_demand_percentage_above_base_capacity = var.on_demand_cpu_percentage_above_base_capacity
      autoscaling_enabled                      = true
      kubelet_extra_args                       = "--node-labels=node.kubernetes.io/lifecycle=cpu,node-type=cpu --register-with-taints=node-type=cpu:NoSchedule"
      suspended_processes                      = ["AZRebalance"]
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/label/node-type"
          "propagate_at_launch" = "false"
          "value"               = "cpu"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/taint/node-type"
          "propagate_at_launch" = "false"
          "value"               = "cpu:NoSchedule"
        }
      ]
    },
    {
      name                                     = "on-demand-gpu-1"
      override_instance_types                  = var.on_demand_gpu_instance_type
      asg_max_size                             = var.on_demand_gpu_max_cluster_size
      asg_min_size                             = var.on_demand_gpu_min_cluster_size
      asg_desired_capacity                     = var.on_demand_gpu_desired_capacity
      asg_recreate_on_change                   = var.on_demand_gpu_asg_recreate_on_change
      on_demand_allocation_strategy            = var.on_demand_gpu_allocation_strategy
      on_demand_base_capacity                  = var.on_demand_gpu_base_capacity
      on_demand_percentage_above_base_capacity = var.on_demand_gpu_percentage_above_base_capacity
      autoscaling_enabled                      = true
      ami_id                                   = data.aws_ami.eks_gpu_worker.id
      kubelet_extra_args                       = "--node-labels=node.kubernetes.io/lifecycle=gpu,node-type=gpu,nvidia.com/gpu=gpu --register-with-taints=node-type=gpu:NoSchedule,nvidia.com/gpu=gpu:NoSchedule"
      suspended_processes                      = ["AZRebalance"]
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/label/node-type"
          "propagate_at_launch" = "false"
          "value"               = "gpu"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/label/nvidia.com/gpu"
          "propagate_at_launch" = "false"
          "value"               = "gpu"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/taint/node-type"
          "propagate_at_launch" = "false"
          "value"               = "gpu:NoSchedule"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/taint/nvidia.com/gpu"
          "propagate_at_launch" = "false"
          "value"               = "gpu:NoSchedule"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/resources/nvidia.com/gpu"
          "propagate_at_launch" = "false"
          "value"               = "1" # Change to the number of GPUs on your node type
        }
      ]
    },
  ]
}
