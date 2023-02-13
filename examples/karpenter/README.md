# About

That example demonstrates how to configure the EKS cluster with Karpenter,sak-karpenter-provisioner and sak-argocd instaled. 
## [Karpenter](https://karpenter.sh/v0.24.0/)

Karpenter automatically provisions new nodes in response to unschedulable pods. Karpenter does this by observing events within the Kubernetes cluster, and then sending commands to the underlying cloud provider.
## How to use
Karpenter can be installed in eks managed node group or in farget profile.To choose between this two use karpenter_mode variable.
Provisioners for karpenter are configured with using of sak-karpenter-provisioner.You can finde more information about how to use sak-karpenter-provisioner [here](https://github.com/provectus/sak-karpenter-provisioner/blob/main/README.md).

For access to argocd, you needs to establish port forwarding for Kubernetes service, you can do it by the next command:
``` bash
kubectl -n argocd port-forward svc/argocd-server  8080:80
```
Now you can open <http://127.0.0.1:8080> in a browser, the password for accessing ArgoCD UI is stored in AWS System Manager Parameter store, you can retrieve it by command:
``` bash
aws --region <your-region> ssm get-parameter  --with-decryption --name /<your-cluster-name>/argocd/password | jq -r '.Parameter.Value' 
```
Login username is `admin`.

## Used modules
| Name | Source | Version |
|------|--------|---------|
| vpc | terraform-aws-modules/vpc/aws | v2.64.0 |
| eks | terraform-aws-modules/eks/aws | v19.6.0 |
| karpenter | terraform-aws-modules/eks/aws//modules/karpenter | v19.6.0 |
| iam | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | v5.2.0|
| argocd | github.com/provectus/sak-argocd | n/a |
| default_provisioner, provisioners | github.com/provectus/sak-karpenter-provisioner | n/a |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| [hashicorp/local](https://registry.terraform.io/providers/hashicorp/local/latest/docs) | >= 2.2.3 |
| [gavinbunney/kubectl](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs) | >= 1.14 |
| [hashicorp/aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) | >= 4.35.0 |
| [hashicorp/external](https://registry.terraform.io/providers/hashicorp/external/latest/docs) | 2.2.2 |
| [hashicorp/helm](https://registry.terraform.io/providers/hashicorp/helm/latest) | 2.9.0|
| [hashicorp/kubernetes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest) | 2.14.0 |
| [hashicorp/null](https://registry.terraform.io/providers/hashicorp/null/latest/docs) | 3.1.1 |
| [hashicorp/random](https://registry.terraform.io/providers/hashicorp/random/latest) | 3.4.3 |
