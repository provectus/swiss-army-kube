# Scaling

The module installs two kind of autoscaler applications: 
- [Cluster Autoscaler](https://github.com/kubernetes/autoscaler) - managing the number of EKS nodes.
- [Horizontal Pod Autoscaler](https://github.com/banzaicloud/hpa-operator) - managing number of deployment replicas.

## Example

``` hcl
module scaling {
  depends_on = [module.argocd]

  source       = "git::https://github.com/provectus/sak-scaling.git"
  cluster_name = module.kubernetes.cluster_name
  argocd       = module.argocd.state
}
```

## Providers
| Name | Version |
|------|---------|
| aws | >= 2.0, < 4.0 |
| helm | >= 0.10, < 2.0 |
| kubernetes | >= 1.11 |
| local | n/a |

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| argocd | A set of values for enabling deployment through ArgoCD | `map(string)` | `{}` | no |
| cluster\_autoscaler\_chart\_version | Version of Cluster Autoscaler chart | `string` | `"7.2.2"` | no |
| cluster\_autoscaler\_conf | A set of parameters to pass to Cluster Autoscaler Helm chart (see: https://github.com/kubernetes/autoscaler) | `map` | `{}` | no |
| cluster\_autoscaler\_enabled | Whether to deploy Cluster Autoscaler chart | `bool` | `true` | no |
| cluster\_name | The name of the cluster the charts will be deployed to | `string` | n/a | yes |
| hpa\_chart\_version | Version of Horizontal Pod Autoscaler chart | `string` | `"0.2.4"` | no |
| hpa\_conf | A set of parameters to pass to Horizontal Pod Autoscaler Helm chart (see: https://github.com/banzaicloud/hpa-operator) | `map` | `{}` | no |
| hpa\_enabled | Whether to deploy Horizontal Pod Autoscaler chart | `bool` | `true` | no |
| module\_depends\_on | A list of explicit dependencies for the module | `list` | `[]` | no |
| namespace | A name of the existing namespace | `string` | `"kube-system"` | no |
| namespace\_name | A name of namespace for creating | `string` | `"scaling"` | no |

## Outputs
No output.
