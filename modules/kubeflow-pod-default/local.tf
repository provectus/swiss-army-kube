locals {

role_to_assume_arn = var.external_secrets_secret_role_arn == "" ? module.iam_assumable_role[0].this_iam_role_arn : var.external_secrets_secret_role_arn
for_each = {for pod-default in var.kubeflow_pod-defaults: pd.name => pd}
content = <<EOT

apiVersion: 'kubernetes-client.io/v1'
kind: ExternalSecret
metadata:
  name: ${each.value.name}
  namespace: ${each.value.namespace}
spec:
  backendType: secretsManager
  roleArn: ${local.role_to_assume_arn}
  data:
    - key: ${each.value.secret}
      name: ${each.value.name}    
---
apiVersion: "kubeflow.org/v1alpha1"
kind: PodDefault
metadata:
  name: ${each.value.name}
  namespace: ${each.value.namespace}
spec:
 selector:
  matchLabels:
    git-config: "true"
 desc: "Add Git Credentials"
 volumeMounts:
 - name: git
   mountPath: /home/git
 volumes:
 - name: git
   secret:
    secretName: ${each.value.name}
EOT
 filename = "${path.root}/${var.argocd.path}/profiles/profile-${each.value.namespace}-${each.value.name}.yaml" # TODO, this is a hack to make sure the poddefault is rolled out with the Profiles. Should be improved later!
}