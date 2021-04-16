# ArgoCD
Module install Argo Events application to Kubernetes cluster.
## Features
- IRSA annotations

## Example
``` hcl 
module argo_events {
  source        = "git::https://github.com/provectus/swiss-army-kube.git//modules/cicd/argo/modules/events"

  cluster_name  = "testing"
}
```

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| helm | n/a |
| kubernetes | n/a |
| local | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| argocd | A set of values for enabling deployment through ArgoCD | `map(string)` | `{}` | no |
| chart\_version | A Helm Chart version | `string` | `"1.0.0"` | no |
| cluster\_name | A name of the Amazon EKS cluster | `string` | n/a | yes |
| conf | A custom configuration for deployment | `map(string)` | `{}` | no |
| iam\_policy | A IAM policy for attaching to role for service account | `any` | `{}` | no |
| module\_depends\_on | A list of explicit dependencies | `list(any)` | `[]` | no |
| namespace | A name of the existing namespace | `string` | `""` | no |
| namespace\_name | A name of namespace for creating | `string` | `"argo-events"` | no |
| tags | A tags for attaching to new created AWS resources | `map(string)` | `{}` | no |

## Outputs

No output.