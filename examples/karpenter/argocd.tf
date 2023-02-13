module "argocd" {
  depends_on = [module.default_provisioner]
  source     = "github.com/provectus/sak-argocd"

  branch       = var.argocd.branch
  owner        = var.argocd.owner
  repository   = var.argocd.repository
  cluster_name = module.eks.cluster_name
  path_prefix  = "examples/karpenter/"

  domains = local.domain
  ingress_annotations = {
    "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
  }
  conf = {
    "server.service.type"     = "ClusterIP"
    "server.ingress.paths[0]" = "/"
  }
}
module "provisioners" {
  source = "github.com/provectus/sak-karpenter-provisioner"

  cluster_name = var.cluster_name
  argocd_enabled = true
  argocd = module.argocd.state

  provisioners = {
    cpu-optimized = {
      requirements = [
        {
          key      = "karpenter.sh/capacity-type"
          operator = "In"
          values   = ["spot"]
        },
        {
          key      = "karpenter.k8s.aws/instance-family"
          operator = "In"
          values   = [ "c5","c6i"]
        },
      ]
      labels = {
        workflow-type = "cpu-optimized"
      }
      container_runtime = "containerd"
      consolidation_enabled = true
    },
  }
  depends_on = [
    module.argocd
  ]
}
