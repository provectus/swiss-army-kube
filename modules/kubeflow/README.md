# Kubeflow

The Kubeflow project is dedicated to making deployments of machine learning (ML) workflows on Kubernetes simple, portable and scalable. Our goal is not to recreate other services, but to provide a straightforward way to deploy best-of-breed open-source systems for ML to diverse infrastructures. Anywhere you are running Kubernetes, you should be able to run Kubeflow.


## Requirements
The Kubernetes cluster must meet the following minimum requirements:

* Your cluster must include at least one worker node with a minimum of:
  * 4 CPU
  * 50 GB storage
  * 12 GB memory
* The recommended Kubernetes version is 1.14. Kubeflow has been validated and tested on Kubernetes 1.14.
  * Your cluster must run at least Kubernetes version 1.11.
  * Kubeflow does not work on Kubernetes 1.16.
  * Older versions of Kubernetes may not be compatible with the latest Kubeflow versions. The following matrix provides information about compatibility between Kubeflow and Kubernetes versions.

| Kubernetes Versions | Kubeflow 0.4 | Kubeflow 0.5 | Kubeflow 0.6 | Kubeflow 0.7 | Kubeflow 1.0    |
|---------------------|--------------|--------------|--------------|--------------|-----------------|
| 1.11                | compatible   | compatible   | incompatible | incompatible | incompatible    |
| 1.12                | compatible   | compatible   | incompatible | incompatible | incompatible    |
| 1.13                | compatible   | compatible   | incompatible | incompatible | incompatible    |
| 1.14                | compatible   | compatible   | compatible   | compatible   | compatible      |
| 1.15                | incompatible | compatible   | compatible   | compatible   | compatible      |
| 1.16                | incompatible | incompatible | incompatible | incompatible | no known issues |
| 1.17                | incompatible | incompatible | incompatible | incompatible | no known issues |
| 1.18                | incompatible | incompatible | incompatible | incompatible | no known issues |

* incompatible: the combination does not work at all
* compatible: all Kubeflow features have been tested and verified for the Kubernetes version
* no known issues: the combination has not been fully tested but there are no repoted issues

## Prerequisites

#### kubectl  
`brew install kubernetes-cli`

#### awscli  
`brew install awscli`

#### aws-iam-authenticator  
`brew install aws-iam-authenticator`

#### kfctl 
`bash swiss-army-kube/kfctl_install.sh`

( To run kfctl, go to the `/usr/local/bin/kfctl` binary file in Finder, right-click, then select Open. Then click Open again to confirm that you want to open the app. )

#### jq
`brew install jq`

## How to update SAK module kubeflow
To add some modifications or custom overlays make changes in `modules/kubeflow/sak_kustomize` folder and `kfctl.yaml` configuration file. `modules/kubeflow/sak_kustomize` folder contains delta which is applied to original Kubeflow modules during deployment. This folder has same structure as original Kubeflow `kustomize` folder.

__NOTE!!!__ any changes in `modules/kubeflow/sak_kustomize` folder and `kfctl.yaml` configuration file will trigger Kubeflow terraform resources recreation.

To apply changes run:
```
terraform plan -out plan
terraform apply plan
```

## Dashboard access

```
export NAMESPACE=istio-system
KUBECONFIG=kubeconfig_swiss-army kubectl port-forward -n ${NAMESPACE} svc/istio-ingressgateway 8080:80
```

Then open browser http://127.0.0.1:8080