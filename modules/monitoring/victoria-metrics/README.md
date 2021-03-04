# Prometheus Stack
Install the [victoria-metrics-cluster](https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-cluster).

## Example
``` hcl
module scaling {
  source        = "git::https://github.com/provectus/swiss-army-kube.git//modules/monitoring/victoria-metrics"
  cluster_name  = "swiss-army-kube"
}
```

#### Remote write for Prometheus

Add this sections to config:

```
grafana:
  additionalDataSources:
    - name: VictoriaMetrics
      type: prometheus
      access: proxy
      url: http://victoria-metrics-cluster-vmselect:8481/select/0/prometheus

prometheus:
  prometheusSpec:
    remoteWrite:
      - url: http://victoria-metrics-cluster-vminsert:8480/insert/0/prometheus/api/v1/write
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
| chart\_version | A Helm Chart version | `string` | `"0.8.10"` | no |
| cluster\_name | A name of the Amazon EKS cluster | `string` | n/a | yes |
| conf | A custom configuration for deployment | `map(string)` | `{}` | no |
| module\_depends\_on | A list of explicit dependencies | `list(any)` | `[]` | no |
| namespace | A name of the existing namespace | `string` | `""` | no |
| namespace\_name | A name of namespace for creating | `string` | `"monitoring"` | no |
| tags | A tags for attaching to new created AWS resources | `map(string)` | `{}` | no |
||||||
