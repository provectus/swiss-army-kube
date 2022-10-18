data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_ami" "eks_gpu_worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-gpu-node-${var.cluster_version}-*"]
  }

  most_recent = true
  owners      = ["602401143452"] #// The ID of the owner of the official AWS EKS AMIs.
}

locals {
  environment  = var.environment
  project      = var.project
  cluster_name = var.cluster_name
  domain       = ["${local.cluster_name}.${var.domain_name}"]
  subnets      = module.network.private_subnets

  registry = "https://registry.${local.domain[0]}"

  docker_config_json = jsonencode(
    {
      "\"registry-mirrors\"" = ["\"${local.registry}\""]
  })

  common = [for index, az in var.availability_zones :
    {
      name_prefix                              = "on-demand-common-${index}"
      instance_type                            = var.on_demand_common_instance_type
      override_instance_types                  = var.on_demand_common_override_instance_types
      asg_max_size                             = var.on_demand_common_max_cluster_size
      asg_min_size                             = var.on_demand_common_min_cluster_size
      asg_desired_capacity                     = var.on_demand_common_desired_capacity
      asg_recreate_on_change                   = var.on_demand_common_asg_recreate_on_change
      on_demand_allocation_strategy            = var.on_demand_common_allocation_strategy
      on_demand_base_capacity                  = var.on_demand_common_base_capacity
      on_demand_percentage_above_base_capacity = var.on_demand_common_percentage_above_base_capacity
      autoscaling_enabled                      = false
      subnets                                  = [element(local.subnets, index)]
      kubelet_extra_args                       = "--node-labels=node.kubernetes.io/lifecycle=`curl -s http://169.254.169.254/latest/meta-data/instance-life-cycle`,node-type=common"
      suspended_processes                      = ["AZRebalance"]
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "true"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
          "propagate_at_launch" = "true"
          "value"               = "owned"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/label/node-type"
          "propagate_at_launch" = "true"
          "value"               = "common"
        }
      ]
    }
  ]

  cpu = values({
    "cpu" = {
      name_prefix                              = "on-demand-cpu-"
      instance_type                            = var.on_demand_cpu_instance_type
      override_instance_types                  = var.on_demand_cpu_override_instance_types
      asg_max_size                             = var.on_demand_cpu_max_cluster_size
      asg_min_size                             = var.on_demand_cpu_min_cluster_size
      asg_desired_capacity                     = var.on_demand_cpu_desired_capacity
      asg_recreate_on_change                   = var.on_demand_cpu_asg_recreate_on_change
      on_demand_allocation_strategy            = var.on_demand_cpu_allocation_strategy
      on_demand_base_capacity                  = var.on_demand_cpu_base_capacity
      on_demand_percentage_above_base_capacity = var.on_demand_cpu_percentage_above_base_capacity
      autoscaling_enabled                      = false
      subnets                                  = local.subnets
      kubelet_extra_args                       = join(" ", ["--node-labels=node.kubernetes.io/lifecycle=`curl -s http://169.254.169.254/latest/meta-data/instance-life-cycle`,node-type=cpu", "--register-with-taints=node-type=cpu:NoSchedule"])
      suspended_processes                      = ["AZRebalance"]
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "true"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
          "propagate_at_launch" = "true"
          "value"               = "owned"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/label/node-type"
          "propagate_at_launch" = "true"
          "value"               = "cpu"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/taint/node-type"
          "propagate_at_launch" = "true"
          "value"               = "cpu:NoSchedule"
        }
      ]
    }
  })

  gpu = values({
    "gpu" = {
      name_prefix                              = "on-demand-gpu-"
      instance_type                            = var.on_demand_gpu_instance_type
      override_instance_types                  = var.on_demand_gpu_override_instance_types
      asg_max_size                             = var.on_demand_gpu_max_cluster_size
      asg_min_size                             = var.on_demand_gpu_min_cluster_size
      asg_desired_capacity                     = var.on_demand_gpu_desired_capacity
      asg_recreate_on_change                   = var.on_demand_gpu_asg_recreate_on_change
      on_demand_allocation_strategy            = var.on_demand_gpu_allocation_strategy
      on_demand_base_capacity                  = var.on_demand_gpu_base_capacity
      on_demand_percentage_above_base_capacity = var.on_demand_gpu_percentage_above_base_capacity
      ami_id                                   = data.aws_ami.eks_gpu_worker.id
      autoscaling_enabled                      = false
      subnets                                  = local.subnets
      kubelet_extra_args                       = join(" ", ["--node-labels=node.kubernetes.io/lifecycle=`curl -s http://169.254.169.254/latest/meta-data/instance-life-cycle`,node-type=gpu,nvidia.com/gpu=gpu", "--register-with-taints=node-type=gpu:NoSchedule,nvidia.com/gpu=gpu:NoSchedule"])
      suspended_processes                      = ["AZRebalance"]
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "true"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
          "propagate_at_launch" = "true"
          "value"               = "owned"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/label/node-type"
          "propagate_at_launch" = "true"
          "value"               = "gpu"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/label/nvidia.com/gpu"
          "propagate_at_launch" = "true"
          "value"               = "gpu"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/taint/node-type"
          "propagate_at_launch" = "true"
          "value"               = "gpu:NoSchedule"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/taint/nvidia.com/gpu"
          "propagate_at_launch" = "true"
          "value"               = "gpu:NoSchedule"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/resources/nvidia.com/gpu"
          "propagate_at_launch" = "true"
          "value"               = var.on_demand_gpu_resource_count
        }
      ]
    }
  })
}
module "network" {
  source = "github.com/provectus/sak-vpc"

  availability_zones = var.availability_zones
  environment        = local.environment
  project            = local.project
  cluster_name       = local.cluster_name
  network            = 10
}
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.23.0"
  cluster_version = var.cluster_version
  cluster_name    = local.cluster_name
  kubeconfig_name = local.cluster_name
  subnets         = local.subnets
  vpc_id          = module.network.vpc_id
  enable_irsa     = false
  map_users       = concat(var.admin_arns, var.user_arns)



  # NOTE:
  #  enable cloudwatch logging
  cluster_enabled_log_types     = var.cloudwatch_logging_enabled ? var.cloudwatch_cluster_log_types : []
  cluster_log_retention_in_days = var.cloudwatch_logging_enabled ? var.cloudwatch_cluster_log_retention_days : 90

  tags = {
    Environment = local.environment
    Project     = local.project
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
    additional_userdata  = "sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm && sudo systemctl enable amazon-ssm-agent && sudo systemctl start amazon-ssm-agent"
    bootstrap_extra_args = (var.container_runtime == "containerd") ? "--container-runtime containerd" : "--docker-config-json ${local.docker_config_json}"
  }

  # Note:
  #   If you add here worker groups with GPUs or some other custom resources make sure
  #   to start the node in ASG manually once or cluster autoscaler doesn't find the resources.
  #
  #   After that autoscaler is able to see the resources on that ASG.
  #
  worker_groups_launch_template = concat(local.common, local.cpu, local.gpu)
}

# OIDC cluster EKS settings
resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  url             = module.eks.cluster_oidc_issuer_url
}

# module "kubernetes" {
#   depends_on = [module.network]
#   source     = "github.com/provectus/sak-kubernetes"

#   environment        = local.environment
#   project            = local.project
#   availability_zones = var.availability_zones
#   cluster_name       = local.cluster_name
#   domains            = local.domain
#   vpc_id             = module.network.vpc_id
#   subnets            = module.network.private_subnets

#   on_demand_gpu_instance_type = "g4dn.xlarge"
# }

module "argocd" {
  depends_on = [module.network.vpc_id, module.eks.cluster_id, data.aws_eks_cluster.cluster]
  source     = "github.com/provectus/sak-argocd"

  branch       = var.argocd.branch
  owner        = var.argocd.owner
  repository   = var.argocd.repository
  cluster_name = module.eks.cluster_id
  path_prefix  = "examples/argocd/"

  domains = local.domain
  ingress_annotations = {
    "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    "kubernetes.io/ingress.class"              = "nginx"
  }
  conf = {
    "server.service.type"     = "ClusterIP"
    "server.ingress.paths[0]" = "/"
  }
}