# Nginx Ingress Controller
## Example
``` hcl
module nginx {
  source       = "git::https://github.com/provectus/swiss-army-kube.git//modules/ingress/nginx"
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
| aws\_private | Set true or false to use private or public infrastructure | `bool` | `false` | no |
| cluster\_name | The name of the cluster the charts will be deployed to | `string` | n/a | yes |
| conf | A set of parameters to pass to Nginx Ingress Controller chart | `map` | `{}` | no |
| module\_depends\_on | A list of explicit dependencies for the module | `list` | `[]` | no |
| namespace | A name of the existing namespace | `string` | `""` | no |
| namespace\_name | A name of namespace for creating | `string` | `"ingress-system"` | no |

## Outputs
No output.