data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_region" "current" {}


module "iam_assumable_role_admin" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  # version                       = "~> v2.6.0"
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

resource "aws_iam_policy" "this" {
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

resource "kubernetes_namespace" "this" {
  depends_on = [
    var.module_depends_on
  ]
  metadata {
    name = var.namespace
  }
}

resource "local_file" "this" {
  depends_on = [
    var.module_depends_on
  ]
  content  = yamlencode(local.application)
  filename = "${path.root}/${var.argocd.path}/${local.name}.yaml"
}

resource "local_file" "issuers_bom" {
  depends_on = [
    var.module_depends_on
  ]
  content  = yamlencode(local.issuers_application)
  filename = "${path.root}/${var.argocd.path}/${local.name}-issuers.yaml"
}

resource "local_file" "issuers" {
  for_each = local.issuers
  depends_on = [
    var.module_depends_on
  ]
  content  = yamlencode(each.value)
  filename = "${path.root}/${var.argocd.path}/issuers/${local.name}-${each.key}.yaml"
}

locals {
  namespace  = kubernetes_namespace.this.id
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
        "value" = domain
      }
    })
  )
  issuers = {
    "staging" = {
      "apiVersion" = "cert-manager.io/v1alpha2"
      "kind"       = "ClusterIssuer"
      "metadata" = {
        "name" = "letsencrypt-staging"
      }
      "spec" = {
        "acme" = {
          "server" = "https://acme-staging-v02.api.letsencrypt.org/directory"
          "email"  = var.email
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
        "name" = "letsencrypt-prod"
      }
      "spec" = {
        "acme" = {
          "server" = "https://acme-v02.api.letsencrypt.org/directory"
          "email"  = var.email
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
  issuers_application = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "${local.name}-issuers"
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = local.namespace
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = var.argocd.repository
        "targetRevision" = var.argocd.branch
        "path"           = "${var.argocd.full_path}/issuers"
      }
      "syncPolicy" = {
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
      }
    }
  }
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
