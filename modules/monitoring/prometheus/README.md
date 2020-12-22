# Prometheus Stack
Install the [kube-prometheus-stack](https://github.com/prometheus-operator/kube-prometheus), de-facto standard for monitoring. 

## Example
``` hcl
module scaling {
  source        = "git::https://github.com/provectus/swiss-army-kube.git//modules/monitoring/prometheus"
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
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| argocd | A set of values for enabling deployment through ArgoCD | `map(string)` | `{}` | no |
| chart\_version | A Helm Chart version | `string` | `"12.8.0"` | no |
| cluster\_name | A name of the Amazon EKS cluster | `string` | n/a | yes |
| conf | A custom configuration for deployment | `map(string)` | `{}` | no |
| domains | A list of domains to use for ingresses | `list(string)` | `[]` | no |
| grafana\_allowed\_domains | Allowed domain for Grafana Google auth | `string` | `"local"` | no |
| grafana\_client\_id | The id of the client for Grafana Google auth | `string` | `""` | no |
| grafana\_client\_secret | The token of the client for Grafana Google auth | `string` | `""` | no |
| grafana\_google\_auth | Enables Google auth for Grafana | `string` | `false` | no |
| grafana\_password | Password for grafana admin | `string` | `""` | no |
| module\_depends\_on | A list of explicit dependencies | `list(any)` | `[]` | no |
| namespace | A name of the existing namespace | `string` | `""` | no |
| namespace\_name | A name of namespace for creating | `string` | `"monitoring"` | no |
| tags | A tags for attaching to new created AWS resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| path\_to\_grafana\_password | A SystemManager ParemeterStore key with Grafana admin password |