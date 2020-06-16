# Kubeflow

The Kubeflow project is dedicated to making deployments of machine learning (ML) workflows on Kubernetes simple, portable and scalable. Our goal is not to recreate other services, but to provide a straightforward way to deploy best-of-breed open-source systems for ML to diverse infrastructures. Anywhere you are running Kubernetes, you should be able to run Kubeflow.


## Requirements


## Settings


## How update SAK module kubeflow


## Dashboard access

```
export NAMESPACE=istio-system
KUBECONFIG=kubeconfig_swiss-test kubectl port-forward -n ${NAMESPACE} svc/istio-ingressgateway 8080:80
```
Then open browser http://127.0.0.1:8080