Deploys Cluster Autoscaler (https://github.com/kubernetes/autoscaler) and Horizontal Pod Autoscaler (https://github.com/banzaicloud/hpa-operator) operator charts.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12, < 0.14 |
| aws | >= 2.0, < 4.0 |
| helm | >= 0.10, < 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.0, < 4.0 |
| helm | >= 0.10, < 2.0 |
| kubernetes | >= 1.11 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_autoscaler\_chart\_version | Version of Cluster Autoscaler chart | `string` | `"7.2.2"` | no |
| cluster\_autoscaler\_conf | A set of parameters to pass to Cluster Autoscaler Helm chart (see: https://github.com/kubernetes/autoscaler) | `map` | `{}` | no |
| cluster\_autoscaler\_enabled | Whether to deploy Cluster Autoscaler chart | `bool` | `true` | no |
| cluster\_name | The name of the cluster the charts will be deployed to | `string` | n/a | yes |
| hpa\_chart\_version | Version of Horizontal Pod Autoscaler chart | `string` | `"0.2.4"` | no |
| hpa\_conf | A set of parameters to pass to Horizontal Pod Autoscaler Helm chart (see: https://github.com/banzaicloud/hpa-operator) | `map` | `{}` | no |
| hpa\_enabled | Whether to deploy Horizontal Pod Autoscaler chart | `bool` | `true` | no |
| module\_depends\_on | A list of explicit dependencies for the module | `list` | `[]` | no |
| namespace | A namespace where Helm charts will be deployed to | `string` | `"kube-system"` | no |

## Outputs

No output.
