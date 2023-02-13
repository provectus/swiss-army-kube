module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "19.6.0"

  cluster_name = module.eks.cluster_name

  create_irsa                     = true
  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]

  # Since Karpenter is running on an EKS Managed Node group,
  # we can re-use the role that was created for the node group
  create_iam_role = var.karpenter_mode == "FARGATE-PROFILE"
  iam_role_arn    = var.karpenter_mode == "EKS-MANAGED-NODE-GROUP" ? module.eks.eks_managed_node_groups["initial"].iam_role_arn : null

  iam_role_additional_policies = var.karpenter_mode == "EKS-MANAGED-NODE-GROUP" ? [] : [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

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
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
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
resource "kubectl_manifest" "default_karpenter_provisioner" {
  yaml_body = <<-YAML
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
spec:
  requirements:
  - key: "kubernetes.io/os"
    operator: In
    values: ["linux"] 
  - key: "karpenter.k8s.aws/instance-size"
    operator: In
    values: [ nano, micro, small, large, medium ]
  - key: "karpenter.k8s.aws/instance-family"
    operator: In
    values: [ "m5" ]
  - key: karpenter.k8s.aws/instance-category
    operator: In
    values: ["m"]
  - key: karpenter.sh/capacity-type
    operator: In
    values: ["spot","on-demand"]

  kubeletConfiguration: 
    containerRuntime: containerd
  limits:
    resources:
      cpu: 1000
      memory: 1000Gi
  consolidation:
    enabled: true

  providerRef:
    name: default
YAML

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "default_karpenter_node_template" {
  yaml_body = <<-YAML
apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: default
spec:
  subnetSelector:
    karpenter.sh/discovery: "true"
  securityGroupSelector:
    karpenter.sh/discovery: ${module.eks.cluster_name}
  tags:
    karpenter.sh/discovery: ${module.eks.cluster_name}
YAML

  depends_on = [
    helm_release.karpenter
  ]
}
