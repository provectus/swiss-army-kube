# ArgoCD
Module install ArgoCD application to Kubernetes cluster and optionally configure it to track changes of the repository. To read more about ArgoCD please follow to official [documentation](https://argoproj.github.io/argo-cd/).
## Features
- Self-managing
- Encryption possibility with AWS KMS

## Example
Simple use-case without ingresses and authentication, for accessing ArgoCD UI need to configure port-forwarding.
``` hcl 
module argocd {
  source        = "git::https://github.com/provectus/swiss-army-kube.git//modules/cicd/argo/modules/cd"

  branch        = "master"
  owner         = "test-github-onwer"
  repository    = "test-github-iac-repo-name"
  cluster_name  = "testing"
  path_prefix   = "path/for/tf/files/folder/in/repo/"
}
```

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| helm | n/a |
| kubernetes | n/a |
| local | n/a |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| apps\_dir | A folder for ArgoCD apps | `string` | `"apps"` | no |
| branch | A GitHub reference | `string` | n/a | yes, in case of enabling native ArgoCD behaviour  |
| chart\_version | An ArgoCD Helm Chart version | `string` | `"2.7.4"` | no |
| cluster\_name | A name of the EKS cluster | `string` | n/a | yes |
| conf | A custom configuration for ArgoCD deployment | `map(string)` | `{}` | no |
| domains | A list of domains to use | `list(string)` | `[]` | no |
| ingress\_annotations | A set of annotations for ArgoCD Ingress | `map(string)` | `{}` | no |
| module\_depends\_on | A dependency list | `list(any)` | `[]` | no |
| namespace | A name of the existing namespace | `string` | `""` | no |
| namespace\_name | A name of namespace for creating | `string` | `"argocd"` | no |
| oidc | A set of variables required for enabling OIDC | `map(string)` | <pre>{<br>  "id": null,<br>  "pool": null,<br>  "secret": null<br>}</pre> | no |
| owner | An owner of GitHub repository | `string` | n/a | yes, in case of enabling native ArgoCD behaviour  |
| path\_prefix | A path inside a repository,if it redefined then should contain a trailing slash | `string` | n/a | yes, in case of enabling native ArgoCD behaviour |
| project\_name | A name of the ArgoCD project for deploying SAK | `string` | `"default"` | no |
| repository | A GitHub repository wich would be used for IaC needs | `string` | n/a | yes, in case of enabling native ArgoCD behaviour |
| tags | A tags for attaching to new created AWS resources | `map(string)` | `{}` | no |
| vcs | An URI of VCS | `string` | `"https://github.com"` | no |
| vcs\_token | Token for accessing private VCS | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| state | A set of values that required for other modules in case of enabling ArgoCD |