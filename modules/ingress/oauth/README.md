# OAuth2 Proxy
## Example
``` hcl
module nginx {
  source       = "git::https://github.com/provectus/swiss-army-kube.git//modules/ingress/oauth"
  cluster_name = module.kubernetes.cluster_name
}
```

## Providers

| Name | Version |
|------|---------|
| helm | n/a |
| kubernetes | n/a |
| local | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| argocd | A set of values for enabling deployment through ArgoCD | `map(string)` | `{}` | no |
| client\_id | Client id for oauth | `string` | `""` | no |
| client\_secret | Client secrets for oauth | `string` | `""` | no |
| cluster\_name | The name of the cluster the charts will be deployed to | `string` | n/a | yes |
| conf | A set of parameters to pass to chart | `map` | `{}` | no |
| cookie\_secret | random\_string make gen command python -c 'import os,base64; print base64.b64encode(os.urandom(16))' | `string` | `""` | no |
| domains | A list of domains to use | `list(string)` | `[]` | no |
| module\_depends\_on | A list of explicit dependencies for the module | `list` | `[]` | no |
| namespace | A name of the existing namespace | `string` | `""` | no |
| namespace\_name | A name of namespace for creating | `string` | `"ingress-system"` | no |

## Outputs

No output.