data aws_region current {}

resource kubernetes_namespace this {
  depends_on = [
    var.module_depends_on
  ]
  metadata {
    name = "argocd"
  }
}

resource helm_release this {
  depends_on = [
    kubernetes_namespace.this
  ]

  name          = local.name
  repository    = local.repository
  chart         = local.chart
  version       = var.chart_version
  namespace     = kubernetes_namespace.this.metadata[0].name
  recreate_pods = true
  timeout       = 1200

  dynamic set {
    for_each = merge(local.init_conf, local.conf)
    content {
      name  = set.key
      value = set.value
    }
  }
}

data aws_eks_cluster this {
  name = var.cluster_name
}

module iam_assumable_role_admin {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v3.0"
  create_role                   = true
  role_name                     = "${var.cluster_name}_argocd"
  provider_url                  = replace(data.aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.this.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${kubernetes_namespace.this.metadata[0].name}:argocd"]
  tags                          = var.tags
}

resource aws_iam_policy this {
  name_prefix = "argocd"
  description = "EKS ArgoCD policy for cluster ${data.aws_eks_cluster.this.id}"
  policy      = data.aws_iam_policy_document.this.json
}

data aws_iam_policy_document this {
  statement {
    sid    = "ArgoCDOwn"
    effect = "Allow"

    actions = [
      "kms:Decrypt"
    ]

    resources = [aws_kms_key.this.arn]
  }
}

resource kubernetes_config_map decryptor {
  metadata {
    name      = "argocd-decryptor"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    decryptor = <<EOT
#! /usr/bin/env python3

import glob
import os

def decrypt(string):
  import boto3
  import base64
  client = boto3.client('kms')
  meta = client.decrypt(CiphertextBlob=bytes(base64.b64decode("%s==" % string)),KeyId="${aws_kms_key.this.arn}")
  plaintext = meta[u'Plaintext']
  return plaintext.decode()

for file in glob.glob('./*.y*ml'):
  print("---")
  with open(file) as f:
    for line in f:
      if line.find("KMS_ENC:") > 0:
        encrypted = line.split("KMS_ENC")[1].split(":")[1]
        decrypted = decrypt(encrypted)
        line = line.replace("KMS_ENC:%s:" % encrypted, decrypted)
      print(line,end = '')
    EOT
  }
}

resource local_file this {
  depends_on = [
    helm_release.this
  ]
  content  = yamlencode(local.application)
  filename = "${path.root}/${var.apps_dir}/${local.name}.yaml"
}

resource random_password this {
  length  = 20
  special = true
}

resource aws_ssm_parameter this {
  name        = "/${var.cluster_name}/argocd/password"
  type        = "SecureString"
  value       = random_password.this.result
  description = "A password for accessing ArgoCD installation in ${var.cluster_name} EKS cluster"
  tags        = var.tags
}

resource aws_kms_key this {
  description = "ArgoCD key"
  is_enabled  = true
  tags        = var.tags
}

resource aws_kms_ciphertext client_secret {
  key_id    = aws_kms_key.this.key_id
  plaintext = var.oidc.secret
}

locals {
  repoURL    = "https://${var.vcs}/${var.owner}/${var.repository}"
  repository = "https://argoproj.github.io/argo-helm"
  name       = "argocd"
  chart      = "argo-cd"
  init_conf = {
    "server.additionalApplications[0].name"                          = "swiss-army-kube"
    "server.additionalApplications[0].namespace"                     = kubernetes_namespace.this.metadata[0].name
    "server.additionalApplications[0].project"                       = "default"
    "server.additionalApplications[0].source.repoURL"                = local.repoURL
    "server.additionalApplications[0].source.targetRevision"         = var.branch
    "server.additionalApplications[0].source.path"                   = "${var.path_prefix}${var.apps_dir}"
    "server.additionalApplications[0].source.plugin.name"            = "decryptor"
    "server.additionalApplications[0].destination.server"            = "https://kubernetes.default.svc"
    "server.additionalApplications[0].destination.namespace"         = kubernetes_namespace.this.metadata[0].name
    "server.additionalApplications[0].syncPolicy.automated.prune"    = "true"
    "server.additionalApplications[0].syncPolicy.automated.selfHeal" = "true"
  }
  conf = {
    "installCRDs" = "false"
    "dex.enabled" = "false"

    "global.securityContext.fsGroup"                                       = "999"
    "repoServer.env[0].name"                                               = "AWS_DEFAULT_REGION"
    "repoServer.env[0].value"                                              = data.aws_region.current.name
    "repoServer.serviceAccount.create"                                     = "true"
    "repoServer.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.iam_assumable_role_admin.this_iam_role_arn
    "repoServer.volumes[0].name"                                           = "decryptor"
    "repoServer.volumes[0].configMap.name"                                 = "argocd-decryptor"
    "repoServer.volumes[0].configMap.items[0].key"                         = "decryptor"
    "repoServer.volumes[0].configMap.items[0].path"                        = "decryptor"
    "repoServer.volumeMounts[0].name"                                      = "decryptor"
    "repoServer.volumeMounts[0].mountPath"                                 = "/opt/decryptor/bin"
    "server.config.configManagementPlugins" = yamlencode(
      [{
        "name" = "decryptor"
        "init" = {
          "command" = ["/usr/bin/pip3"]
          "args"    = ["install", "boto3"]
        }
        "generate" = {
          "command" = ["/usr/bin/python3"]
          "args"    = ["/opt/decryptor/bin/decryptor"]
        }
      }]
    )
  }
  values = concat([
    {
      "name"  = "server.rbacConfig.policy\\.default"
      "value" = "role:readonly"
    },
    {
      "name"  = "server.rbacConfig.policy\\.csv"
      "value" = <<EOF
g, administrators, role:admin
EOF
    },
    {
      "name" = "server.config.oidc\\.config"
      "value" = yamlencode(
        {
          "name"            = "Cognito"
          "issuer"          = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${var.oidc.pool}"
          "clientID"        = var.oidc.id
          "clientSecret"    = "KMS_ENC:${aws_kms_ciphertext.client_secret.ciphertext_blob}:"
          "requestedScopes" = ["openid", "profile", "email"]
          "requestedIDTokenClaims" = {
            "cognito:groups" = {
              "essential" = true
            }
          }
        }
      )
    },
    {
      "name"  = "server.ingress.paths[0]"
      "value" = "/*"
    },
    {
      "name"  = "server.extraArgs[0]"
      "value" = "--insecure"
    },
    {
      "name"  = "server.service.type"
      "value" = "NodePort"
    },
    {
      "name"  = "configs.secret.argocdServerAdminPassword"
      "value" = bcrypt(random_password.this.result, 10)
    },
    {
      "name"  = "server.ingress.enabled"
      "value" = "true"
    },
    {
      "name"  = "server.config.url"
      "value" = "https://argocd.${var.domains[0]}"
    }

    ],
    values({
      for i, domain in tolist(var.domains) :
      "key" => {
        "name"  = "server.ingress.tls[${i}].hosts[0]"
        "value" = "argocd.${domain}"
      }
    }),
    values({
      for i, domain in tolist(var.domains) :
      "key" => {
        "name"  = "server.ingress.hosts[${i}]"
        "value" = "argocd.${domain}"
      }
    }),
    values({
      for i, domain in tolist(var.domains) :
      "key" => {
        "name"  = "server.ingress.tls[${i}].secretName"
        "value" = "argocd-${domain}-tls"
      }
    }),
    values({
      for key, value in var.ingress_annotations :
      key => {
        "name"  = "server.ingress.annotations.${replace(key, ".", "\\.")}"
        "value" = value
      }
    }),
    values({
      for key, value in local.conf :
      key => {
        "name"  = key
        "value" = tostring(value)
      }
    })
  )
  application = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = local.name
      "namespace" = kubernetes_namespace.this.metadata[0].name
    }
    "spec" = {
      "destination" = {
        "namespace" = kubernetes_namespace.this.metadata[0].name
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = local.repository
        "targetRevision" = var.chart_version
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
