# External DNS
## Example
``` hcl
module external_dns {
  source       = "git::https://github.com/provectus/swiss-army-kube.git//modules/system/external-dns"
  cluster_name = module.kubernetes.cluster_name
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
| aws\_private | Set true or false to use private or public infrastructure | `bool` | `false` | no |
| cluster\_name | The name of the cluster the charts will be deployed to | `string` | n/a | yes |
| conf | A set of parameters to pass to Nginx Ingress Controller chart | `map` | `{}` | no |
| domains | A list of domains to use | `list` | `[]` | no |
| mainzoneid | An ID of the root Route53 zone for creating sub-domains | `string` | `""` | no |
| module\_depends\_on | A list of explicit dependencies for the module | `list` | `[]` | no |
| namespace | A name of the existing namespace | `string` | `"kube-system"` | no |
| namespace\_name | A name of namespace for creating | `string` | `"external-dns"` | no |
| tags | A tags for attaching to new created AWS resources | `map(string)` | `{}` | no |
| vpc\_id | An ID of the VPC for the private Route53 zone | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| zone\_id | An ID of the created Route53 zone |