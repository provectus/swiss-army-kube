data aws_vpc main {
  id = var.vpc_id
}

data aws_eks_cluster this {
  name = var.cluster_name
}

data aws_region current {}


module iam_assumable_role_admin {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.6.0"
  create_role                   = true
  role_name                     = "${data.aws_eks_cluster.this.id}_${local.name}"
  provider_url                  = replace(data.aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.this.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.namespace}:${local.name}"]

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource aws_iam_policy this {
  depends_on = [
    var.module_depends_on
  ]
  name_prefix = "${data.aws_eks_cluster.this.id}-${local.name}-"
  description = "EKS ${local.name} policy for cluster ${data.aws_eks_cluster.this.id}"
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
          Resource = "arn:aws:route53:::hostedzone/${var.zone_id}"
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

data kubernetes_namespace this {
  metadata {
    name = var.namespace
  }
}

resource kubernetes_namespace this {
  depends_on = [
    var.module_depends_on
  ]
  count = lookup(data.kubernetes_namespace.this, "id") != null ? 0 : 1
  metadata {
    name = var.namespace
  }
}

resource local_file this {
  depends_on = [
    var.module_depends_on
  ]
  content  = yamlencode(local.application)
  filename = "${path.root}/apps/${local.name}.yaml"
}

resource local_file issuers {
  for_each = local.issuers
  depends_on = [
    var.module_depends_on
  ]
  content  = yamlencode(each.value)
  filename = "${path.root}/apps/${local.name}-issuer-${each.key}.yaml"
}

locals {
  namespace  = lookup(data.kubernetes_namespace.this, "id") != null ? data.kubernetes_namespace.this.id : kubernetes_namespace.this[0].id
  repository = "https://charts.jetstack.io"
  name       = "cert-manager"
  chart      = "cert-manager"
  version    = "v0.15.1"
  values = concat([
    {
      "name"  = "installCRDs"
      "value" = "true"
    },
    {
      "name"  = "rbac.serviceAccountAnnotations.eks\\.amazonaws\\.com/role-arn"
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
  issuers = {
    "staging" = {
      "apiVersion" = "cert-manager.io/v1alpha2"
      "kind"       = "ClusterIssuer"
      "metadata" = {
        "name" = "staging"
      }
      "spec" = {
        "acme" = {
          "server" = "https://acme-staging-v02.api.letsencrypt.org/directory"
          "email"  = "var.email"
          "privateKeySecretRef" = {
            "name" = "letsencrypt-staging"
          }
          "solvers" = [
            {
              "dns01" = {
                "route53" = {
                  "region"       = data.aws_region.current.name
                  "hostedZoneID" = var.zone_id
                }
              }
            }
          ]
        }
      }
    }
    "prod" = {
      "apiVersion" = "cert-manager.io/v1alpha2"
      "kind"       = "ClusterIssuer"
      "metadata" = {
        "name" = "prod"
      }
      "spec" = {
        "acme" = {
          "server" = "https://acme-v02.api.letsencrypt.org/directory"
          "email"  = "var.email"
          "privateKeySecretRef" = {
            "name" = "letsencrypt-prod"
          }
          "solvers" = [
            {
              "dns01" = {
                "route53" = {
                  "region"       = data.aws_region.current.name
                  "hostedZoneID" = var.zone_id
                }
              }
            }
          ]
        }
      }
    }
  }
  application = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = local.name
      "namespace" = "argocd"
    }
    "spec" = {
      "destination" = {
        "namespace" = local.namespace
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = local.repository
        "targetRevision" = local.version
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
