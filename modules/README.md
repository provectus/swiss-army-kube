# Modules 

The [Modules](https://github.com/provectus/swiss-army-kube/tree/master/modules) directory contains Terraform modules that you can use in your projects. Modules are a collection of services that you can deploy on top of your EKS Kubernetes cluster to enable logging, monitoring, certificate management, automatic discovery of Kubernetes resources via public DNS servers, and other common infrastructure needs.

## Using SAK Modules

To use modules in your cluster, include some in your project by uncommenting them in the `modules.tf` file, set variables for these modules in the `example.tfvars` file, and deploy your cluster.
To add or destroy a module, add/remove it in the modules.tf file and run: 
```
terraform plan -out plan && terraform apply plan
```
## All SAK Modules

SAK Modules: 

* [Core Modules](#core)
* [Optional Modules](#optional)

Some of the SAK modules are core - you can't deploy a cluster without them. Cure modules are in bold in the list below. Other modules are optional.

*  [airflow](https://github.com/provectus/swiss-army-kube/tree/master/modules/airflow) 
*  [cicd](https://github.com/provectus/swiss-army-kube/tree/master/modules/cicd)
    + [argo](https://github.com/provectus/swiss-army-kube/tree/master/modules/cicd/argo)
    + [jenkins](https://github.com/provectus/swiss-army-kube/tree/master/modules/cicd/jenkins)
*  [ingress](https://github.com/provectus/swiss-army-kube/tree/master/modules/ingress)
    + [alb-ingress](https://github.com/provectus/swiss-army-kube/tree/master/modules/ingress/alb-ingress)
    + [nginx](https://github.com/provectus/swiss-army-kube/tree/master/modules/ingress/nginx)
*   [kubeflow](https://github.com/provectus/swiss-army-kube/tree/master/modules/kubeflow)
    + [sak_kustomize](https://github.com/provectus/swiss-army-kube/tree/master/modules/kubeflow/sak_kustomize)
*   **[kubernetes](https://github.com/provectus/swiss-army-kube/tree/master/modules/kubernetes)**
*   [logging](https://github.com/provectus/swiss-army-kube/tree/master/modules/logging)
    + [efk](https://github.com/provectus/swiss-army-kube/tree/master/modules/logging/efk)
    + [loki](https://github.com/provectus/swiss-army-kube/tree/master/modules/logging/loki)
*   [monitoring](https://github.com/provectus/swiss-army-kube/tree/master/modules/monitoring)
    + [prometheus](https://github.com/provectus/swiss-army-kube/tree/master/modules/monitoring/prometheus)
*   **[network](https://github.com/provectus/swiss-army-kube/tree/master/modules/network)**
*   [rds](https://github.com/provectus/swiss-army-kube/tree/master/modules/rds) 
*   [scaling](https://github.com/provectus/swiss-army-kube/tree/master/modules/scaling)
*   [storage](https://github.com/provectus/swiss-army-kube/tree/master/modules/storage)
    + [efs](https://github.com/provectus/swiss-army-kube/tree/master/modules/storage/efs)
    + [fsx](https://github.com/provectus/swiss-army-kube/tree/master/modules/storage/fsx)
*  **[system](https://github.com/provectus/swiss-army-kube/tree/master/modules/system)**

<a name="core"></a>
### Core Modules
 
#### 1. Kubernetes 

Kubernetes module is used to deploy the EKS cluster in Amazon. It creates an autoscaling group (ASG) of EC2 instances in selected accessibility zones and runs containers on those instances, maintaining and scaling them. 

#### 2. Network

Network module is a VPC module for creating networks, load balancers, and gateways.

#### 3. System

System module configures an EKS cluster with addons and Helm charts - cert-manager (ExternalDNS), external-dns, saled-secrets, kube-state-metrics. Cert-manager is a native Kubernetes certificate management addon to automate issuance and management of TLS certificates. ExternalDNS addon makes Kubernetes resources discoverable via public DNS servers. kube-state-metrics Helm Chart listens to the Kubernetes API server and generates metrics about the state of the objects (deployments, nodes and pods). sealed-secrets manages secretes. 

<a name="optional"></a>
### Optional Modules   

Other (non-core) modules are optional. You can include them in your project by uncommenting them in the `modules.tf` file and setting variables for them in the `example.tfvars` file. You can also add your own modules to include in your cluster deployments.