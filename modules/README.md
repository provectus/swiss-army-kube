# swiss-army-kube modules 

### Every new module firstly will be added to our [sak-incubator](https://github.com/provectus/sak-incubator). Unreleased sak-modules are here too. When the module will be ready, we will release it as separate sak-module.
### If you are interested in our project and want to see your Kubernetes tool as SAK-module - please create an [request](https://github.com/provectus/swiss-army-kube/issues) in GitHub.


## Infrastructure
* [sak-kubernetes](https://github.com/provectus/sak-kubernetes) - Bootstrap EKS cluster, based on [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) module.
* [sak-vpc](https://github.com/provectus/sak-vpc) - Prepare VPC and networking for EKS cluster and nodes, based on [terraform-aws-vpc](https://github.com/terraform-aws-modules/terraform-aws-vpc) module.
* [sak-argocd](https://github.com/provectus/sak-argocd) - Argocd deployment, which will be used as main controller of sak-modules configuration.

## Controllers
* [sak-alb-controller](https://github.com/provectus/sak-alb-controller) - Create Elastic Load Balancers in EKS.
* [sak-external-dns](https://github.com/provectus/sak-external-dns) - ExternalDNS synchronizes exposed Kubernetes Services and Ingresses with DNS providers(Route53).
* [sak-scaling](https://github.com/provectus/sak-scaling) - Consist of Node Autoscaler and Horizontal Pod Autoscaler.
* [sak-cert-manager](https://github.com/provectus/sak-cert-manager) - X.509 certificate management for Kubernetes.
* [sak-nginx](https://github.com/provectus/sak-nginx) - Ingress controller for Kubernetes using NGINX as a reverse proxy and load balancer.
* [sak-external-secrets](https://github.com/provectus/sak-external-secrets) -  A Kubernetes operator that integrates external secret management systems like AWS Secrets Manager.

## Monitoring/Observability
* [sak-loki](https://github.com/provectus/sak-loki) - [Grafana Loki](https://grafana.com/oss/loki/), log aggregation and processing system.
* [sak-prometheus](https://github.com/provectus/sak-prometheus) - Prometheus, systems and service monitoring system.
* [sak-efk](https://github.com/provectus/sak-efk) - ElasticSearch + Filebeat + Kibana stack. 
* [sak-victoria-metrics](https://github.com/provectus/sak-victoria-metrics) - Deployment of [Victoria Metrics](https://victoriametrics.com/).

## Authentication
* [sak-oauth](https://github.com/provectus/sak-oauth) - Deployment of [Oauth proxy](https://github.com/oauth2-proxy/oauth2-proxy).
* [sak-cognito](https://github.com/provectus/sak-cognito) - Integration of [AWS Cognito](https://aws.amazon.com/ru/cognito/).

## Specific modules
* [sak-kubeflow](https://github.com/provectus/sak-kubeflow) - Make EKS cluster ML-Ready, using [Kubeflow](https://www.kubeflow.org/).

