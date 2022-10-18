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
