data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_region" "current" {}

resource "kubernetes_namespace" "this" {
  count = var.namespace == "kube-system" ? 0 : 1
  metadata {
    name = var.namespace_name
  }
}

locals {
  argocd_enabled = length(var.argocd) > 0 ? 1 : 0
  namespace      = coalescelist(kubernetes_namespace.this, [{ "metadata" = [{ "name" = var.namespace }] }])[0].metadata[0].name
}

resource "helm_release" "this" {
  count = 1 - local.argocd_enabled
  depends_on = [
    var.module_depends_on
  ]
  name          = local.name
  repository    = local.repository
  chart         = local.chart
  version       = local.chart_version
  namespace     = local.namespace
  recreate_pods = true
  timeout       = 1200

  dynamic "set" {
    for_each = local.conf

    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "aws_route53_record" "ns" {
  depends_on = [
    var.module_depends_on,
  ]
  count   = var.mainzoneid == "" ? 0 : length(var.hostedzones)
  zone_id = var.mainzoneid
  name    = element(var.hostedzones, count.index)
  type    = "NS"
  ttl     = "30"

  records = [
    for num in range(4) :
    element((var.aws_private ? aws_route53_zone.private : aws_route53_zone.public)[count.index].name_servers, num)
  ]
}

resource "aws_route53_zone" "public" {
  depends_on = [
    var.module_depends_on,
  ]

  count = var.aws_private ? 0 : length(var.hostedzones)
  name  = element(var.hostedzones, count.index)

  tags          = var.tags
  force_destroy = true
}

resource "aws_route53_zone" "private" {
  depends_on = [
    var.module_depends_on,
  ]
  count = var.aws_private ? length(var.hostedzones) : 0
  name  = element(var.hostedzones, count.index)
  vpc {
    vpc_id = var.vpc_id
  }
  tags          = var.tags
  force_destroy = true
}

module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v3.6.0"
  create_role                   = true
  role_name                     = "${data.aws_eks_cluster.this.id}_${local.name}"
  provider_url                  = replace(data.aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.this.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.namespace}:${local.name}"]

  tags = var.tags
}

resource "aws_iam_policy" "this" {
  depends_on = [
    var.module_depends_on
  ]
  name_prefix = "${data.aws_eks_cluster.this.id}-external-dns-"
  description = "EKS external-dns policy for cluster ${data.aws_eks_cluster.this.id}"
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect   = "Allow",
          Action   = "route53:GetChange",
          Resource = "arn:aws:route53:::change/*"
        },
        {
          Effect = "Allow",
          Action = [
            "route53:ChangeResourceRecordSets",
            "route53:ListResourceRecordSets"
          ],
          Resource = formatlist("arn:aws:route53:::hostedzone/%s",
          concat(aws_route53_zone.public.*.zone_id, aws_route53_zone.private.*.zone_id))
        },
        {
          Effect = "Allow",
          Action = [
            "route53:ListHostedZonesByName",
            "route53:ListHostedZones",
          ]
          Resource = "*"
        }
      ]
    }
  )
}

resource "local_file" "this" {
  count = local.argocd_enabled
  depends_on = [
    var.module_depends_on
  ]
  content  = yamlencode(local.application)
  filename = "${path.root}/${var.argocd.path}/${local.name}.yaml"
}

locals {
  repository    = "https://charts.bitnami.com/bitnami"
  name          = "external-dns"
  chart         = "external-dns"
  chart_version = var.chart_version
  conf          = merge(local.conf_defaults, var.conf)
  conf_defaults = merge({
    "rbac.create"                                               = true,
    "resources.limits.cpu"                                      = "100m",
    "resources.limits.memory"                                   = "300Mi",
    "resources.requests.cpu"                                    = "100m",
    "resources.requests.memory"                                 = "300Mi",
    "aws.region"                                                = data.aws_region.current.name
    "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.iam_assumable_role_admin.this_iam_role_arn
    },
    {
      for i, zone in tolist(var.hostedzones) :
      "domainFilters[${i}]" => zone
    }
  )
  application = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = local.name
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = local.namespace
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = local.repository
        "targetRevision" = local.chart_version
        "chart"          = local.chart
        "helm" = {
          "parameters" = values({
            for key, value in local.conf :
            key => {
              "name"  = key
              "value" = tostring(value)
            }
          })
        }
      }
      "syncPolicy" = {
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
      }
    }
  }
}
