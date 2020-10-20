# ArgoCD
Module install ArgoCD application to Kubernetes cluster and optionally configure it to track changes of the remote repository
## Features
- Self-managing
- Decryption possibility with AWS KMS
- AWS Cognito authentication

## Example
``` hcl 
module argocd {
  source        = "git::https://github.com/provectus/swiss-army-kube.git//modules/cicd/argo/modules/cd"
  branch        = "master"
  owner         = "test-github-onwer"
  repository    = "test-github-iac-repo-name"
  cluster_name  = "testing"
  domains       = ["test.domain.local"]
  chart_version = "2.7.4"
  ingress_annotations = {
    "kubernetes.io/ingress.class" = "nginx"
  }
}
```