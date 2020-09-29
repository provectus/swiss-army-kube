data aws_vpc main {
  id = var.vpc_id
}

data aws_eks_cluster this {
  name = var.cluster_name
}

data aws_region current {}

resource aws_route53_record ns {
  depends_on = [
    var.module_depends_on,
  ]
  count   = var.mainzoneid == "" ? 0 : length(var.domains)
  zone_id = var.mainzoneid
  name    = element(var.domains, count.index)
  type    = "NS"
  ttl     = "30"

  records = [
    aws_route53_zone.public[count.index].name_servers[0],
    aws_route53_zone.public[count.index].name_servers[1],
    aws_route53_zone.public[count.index].name_servers[2],
    aws_route53_zone.public[count.index].name_servers[3]
  ]
}

resource aws_route53_zone public {
  depends_on = [
    var.module_depends_on,
  ]

  count = var.aws_private == "false" ? length(var.domains) : 0
  name  = element(var.domains, count.index)

  tags = {
    Environment = var.environment
    Project     = var.project
  }
  force_destroy = true
}

resource aws_route53_zone private {
  depends_on = [
    var.module_depends_on,
  ]
  count = var.aws_private == "true" ? length(var.domains) : 0
  name  = element(var.domains, count.index)
  vpc {
    vpc_id = data.aws_vpc.main.id
  }
  tags = {
    Environment = var.environment
    Project     = var.project
  }
  force_destroy = true
}

module iam_assumable_role_admin {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.6.0"
  create_role                   = true
  role_name                     = "${data.aws_eks_cluster.this.id}_${local.name}"
  provider_url                  = replace(data.aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.this.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.namespace}:${local.name}"]

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource aws_iam_policy this {
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

resource kubernetes_namespace this {
  count = var.namespace == "kube-system" ? 0 : 1
  depends_on = [
    var.module_depends_on
  ]
  metadata {
    name = var.namespace
  }
}

resource local_file this {
  depends_on = [
    var.module_depends_on
  ]
  content  = yamlencode(local.application)
  filename = "${path.root}/${var.argocd.path}/${local.name}.yaml"
}

locals {
  repository = "https://charts.bitnami.com/bitnami"
  name       = "external-dns"
  chart      = "external-dns"
  values = concat([
    {
      "name"  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      "value" = module.iam_assumable_role_admin.this_iam_role_arn
    },
    {
      "name"  = "aws.region"
      "value" = data.aws_region.current.name
    }
    ],
    values({
      for i, domain in tolist(var.domains) :
      "key" => {
        "name"  = "domainFilters[${i}]"
        "value" = "${domain}"
      }
    })
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
        "namespace" = var.namespace
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = local.repository
        "targetRevision" = "3.4.0"
        "chart"          = local.chart
        "helm" = {
          "parameters" = local.values
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
