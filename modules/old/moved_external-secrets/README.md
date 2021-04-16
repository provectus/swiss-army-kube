# External Secrets
__warning:__ this module only works with ArgoCD

## Example
``` hcl
module external_secrets {
  source         = "git::https://github.com/provectus/swiss-army-kube.git//modules/system/external-secrets"
  argocd         = module.argocd.state
  cluster_output = module.kubernetes
}
```

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| local | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| allowed\_secrets\_prefix | Prefix of for secrets we should be able to access from the external-secrets app? | `string` | `"/eks/"` | no |
| argocd | A set of values for enabling deployment through ArgoCD | `map(string)` | `{}` | no |
| aws\_assume\_role\_arn | A role to assume | `string` | `""` | no |
| aws\_region | A name of the AWS region (us-central-1, us-west-2 and etc.) | `string` | `""` | no |
| chart\_parameters | A list of parameters that will override defaults | `list` | `[]` | no |
| chart\_parameters\_as\_string | A list of parameters that will override defaults | `list` | `[]` | no |
| chart\_repository | n/a | `string` | `"https://external-secrets.github.io/kubernetes-external-secrets/"` | no |
| chart\_values | Chart values | `string` | `""` | no |
| chart\_version | A Helm Chart version | `string` | `"6.0.0"` | no |
| cluster\_output | Cluster output object from Kubernetes module | `map` | n/a | yes |
| poller\_interval | Interval of refreshing values from secrets manager in ms | `string` | `"30000"` | no |
| tags | A tags for attaching to new created AWS resources | `map(string)` | `{}` | no |

## Outputs

No output.
