module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "19.6.0"

  cluster_name = module.eks.cluster_name

  create_irsa                     = true
  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]

  create_iam_role = var.karpenter_mode == "FARGATE-PROFILE"
  cluster_ip_family = "ipv4"
  iam_role_attach_cni_policy = false
  iam_role_additional_policies = var.karpenter_mode == "EKS-MANAGED-NODE-GROUP" ? [] : [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  # Since Karpenter is running on an EKS Managed Node group,
  # we can re-use the role that was created for the node group
  iam_role_arn    = var.karpenter_mode == "EKS-MANAGED-NODE-GROUP" ? module.eks.eks_managed_node_groups["initial"].iam_role_arn : null

  enable_spot_termination = true

  tags = {
    Environment = local.environment
    Project     = local.project
  }
}

resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  chart               = "karpenter"
  version             = "v0.23.0"

  set {
    name  = "settings.aws.clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "settings.aws.clusterEndpoint"
    value = module.eks.cluster_endpoint
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter.irsa_arn
  }

  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = module.karpenter.instance_profile_name
  }

  set {
    name  = "settings.aws.interruptionQueueName"
    value = module.karpenter.queue_name
  }

  dynamic "set" {
    for_each = var.karpenter_mode == "EKS-MANAGED-NODE-GROUP" ? [1] : []
    content {
      name  = "nodeSelector.CriticalAddonsOnly"
      value = "dedicated"
    }
  }
  depends_on = [
    module.eks
  ]
}
module "default_provisioner" {
  source = "github.com/provectus/sak-karpenter-provisioner"

  cluster_name = var.cluster_name
  argocd_enabled = false

  provisioners = {
    default = {
      requirements = [
        {
          key      = "karpenter.k8s.aws/instance-family"
          operator = "In"
          values   = [ "m5" ]
        },
        {
          key      = "karpenter.sh/capacity-type"
          operator = "In"
          values   = ["spot", "on-demand"]
        },
        {
          key      = "karpenter.k8s.aws/instance-size"
          operator = "In"
          values   = [ "nano", "micro", "small", "large", "medium" ]
        },
      ]
      resources_limits = {
        cpu = "1000" 
        memory = "1000Gi"
      }
      container_runtime = "containerd"
      consolidation_enabled = true
    },
  }
  depends_on = [
    helm_release.karpenter
  ]
}