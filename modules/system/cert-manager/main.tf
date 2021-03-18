data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_region" "current" {}

resource "kubernetes_namespace" "this" {
  depends_on = [
    var.module_depends_on
  ]
  count = var.namespace == "" ? 1 : 0
  metadata {
    name = var.namespace_name
  }
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
  name_prefix = "${data.aws_eks_cluster.this.id}-cert-manager-"
  description = "EKS cert-manager policy for cluster ${data.aws_eks_cluster.this.id}"
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
          Resource = formatlist("arn:aws:route53:::hostedzone/%s", var.hostedZoneID)
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

resource "helm_release" "this" {
  count = 1 - local.argocd_enabled
  depends_on = [
    var.module_depends_on
  ]
  name       = local.name
  repository = local.repository
  chart      = local.chart
  version    = local.version
  namespace  = local.namespace
  timeout    = 1200

  dynamic "set" {
    for_each = local.conf

    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "local_file" "this" {
  count    = local.argocd_enabled
  content  = yamlencode(local.app)
  filename = "${var.argocd.path}/${local.name}.yaml"
}

resource "local_file" "issuer" {
  count    = local.argocd_enabled
  content  = yamlencode(local.issuer)
  filename = "${var.argocd.path}/${local.name}-issuer.yaml"
}

locals {
  argocd_enabled = length(var.argocd) > 0 ? 1 : 0
  namespace      = coalescelist(kubernetes_namespace.this, [{ "metadata" = [{ "name" = var.namespace }] }])[0].metadata[0].name

  name         = "cert-manager"
  repository   = "https://charts.jetstack.io"
  chart        = "cert-manager"
  version      = var.chart_version
  email        = var.email
  domains      = var.domain
  region       = data.aws_region.current.name
  hostedZoneID = var.hostedZoneID

  issuer = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt-prod"
    }
    "spec" = {
      "acme" = {
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "email"  = local.email
        "privateKeySecretRef" = {
          "name" = "letsencrypt-prod-account-key"
        }
        "solvers" = [
          {
            "selector" = {
              "dnsZones" = ["${local.domains}"]
            }
            "dns01" = {
              "route53" = {
                "region"       = local.region
                "hostedZoneID" = local.hostedZoneID
              }
            }
          },
        ]
      }
    }
  }
  app = {
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

  conf = merge(local.conf_defaults, var.conf)
  conf_defaults = merge(
    var.aws_private ? {
      //TODO: set external DNS and issuers
    } : {},
    {
      "installCRDs"                                               = true
      "securityContext.enabled"                                   = true
      "securityContext.fsGroup"                                   = "1001"
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.iam_assumable_role_admin.this_iam_role_arn
      "ingressShim.defaultIssuerName"                             = "letsencrypt-prod" //TODO:metadata.name.issuer
      "ingressShim.defaultIssuerKind"                             = "ClusterIssuer"
      "global.leaderElection.namespace"                           = local.namespace

  })
}
