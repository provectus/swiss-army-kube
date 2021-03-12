locals {

  

  role_to_assume_arn = var.external_secrets_secret_role_arn == "" ? module.iam_assumable_role[0].this_iam_role_arn : var.external_secrets_secret_role_arn
  
  pod_default_def = var.pod_default_def != null ? var.pod_default_def : <<EOT
apiVersion: 'kubernetes-client.io/v1'
kind: ExternalSecret
metadata:
  name: ${var.name}
  namespace: ${var.namespace}
spec:
  backendType: secretsManager
  roleArn: ${local.role_to_assume_arn}
  data:
    - key: ${var.key}
      name: ${var.name}    
---
apiVersion: "kubeflow.org/v1alpha1"
kind: PodDefault
metadata:
  name: ${var.name}
  namespace: ${var.namespace}

# TODO!


# spec:
#  selector:
#   matchLabels:
#     add-gcp-secret: "true"
#  desc: "add gcp credential"
#  volumeMounts:
#  - name: secret-volume
#    mountPath: /secret/gcp
#  volumes:
#  - name: secret-volume
#    secret:
#     secretName: gcp-secret
EOT
}