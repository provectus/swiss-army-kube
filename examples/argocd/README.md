# About
That example demonstrates how to configure the EKS cluster with the ArgoCD application. A general idea of the usage of ArgoCD is managing all Kubernetes resources with it. ArgoCD provides us a way of implementing the GitOps methodology for Kubernetes applications.
## Implementation
First of all, you execute Terraform commands as it was for `common` example (please follow these instructions to understand how to use SAK). At this step, you will generate all required AWS resources such as EC2 instances, EKS cluster, IAM roles, etc. Also, Terraform will generate a few local files with ArgoCD applications. 

The next phase is it uploading these files to your GitHub repository. Please follow ArgoProj's documentation for more detailed information about [how it works](https://argoproj.github.io/argo-cd/#how-it-works)
## How to use
That example creates a minimal EKS cluster without any additional software except ArgoCD. So for accessing it needs to establish port forwarding for Kubernetes service, you can do it by next command:
``` bash
kubectl -n argocd port-forward svc/argocd-server  8080:80
```
Now you can open http://127.0.0.1:8080 in a browser, the password for accessing ArgoCD UI is stored in AWS System Manager Paramstore, you can retrieve it by command:
``` bash
aws --region <your-region> ssm get-parameter  --with-decryption --name /<your-cluster-name>/argocd/password | jq -r '.Parameter.Value' 
```