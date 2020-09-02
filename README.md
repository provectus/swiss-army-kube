[![Maintenance](https://img.shields.io/maintenance/yes/2020?style=for-the-badge)]()
[![Apache2](https://img.shields.io/badge/license-Apache2-green.svg?style=for-the-badge)](https://www.apache.org/licenses/LICENSE-2.0)
[![Contributors](https://img.shields.io/github/contributors/provectus/head.svg?style=for-the-badge)](https://github.com/provectus/swiss-army-kube/graphs/contributors) 

<!-- Swiss-Army-Kube_README -->
**[Quickstart](https://github.com/provectus/swiss-army-kube/blob/feature/new_docs/QUICKSTART.md)** • **[Modules](https://github.com/provectus/swiss-army-kube/tree/feature/new_docs/modules)** • **[Configure Deployment](https://github.com/Evanto/qna/wiki/SAK-Configure-Deployment-in-example.tfvars)** • **[Troubleshooting](https://github.com/Evanto/qna/wiki/SAK-Troubleshooting)** • **[Contribute](https://github.com/Evanto/qna/wiki/SAK-Contributing)** • **[Provectus](https://provectus.com/)**


# Swiss Army Kube - Free IaC Tool for Easy EKS Kubernetes Cluster Deployment.  


<img src="https://user-images.githubusercontent.com/20886422/91975571-9639dc00-eced-11ea-9c93-c485aa6636d2.jpg" width="400px" alt="logo"/>&nbsp;

Swiss Army Kube (SAK) is an open-source IaC (Infrastructure as Code) collection of services for quick, easy, and controllable deployment of EKS Kubernetes clusters on Amazon for your projects. With Swiss Army Kube, cluster configuration and provisioning takes just a fraction of time normally spent on manual deployment via AWS management console. SAK automates deployments, making them repeatable, consistent, and less error-prone.

Swiss Army Kube uses Terraform to describe the desired state of your infrastructure (resources that need to be provisioned like IAM roles, ASG, Route 53, subnets, etc.) and build a Kubernetes cluster on AWS EC2 instances.   

SAK provides an example directory that you can use as an easily modifiable template to set up your cluster deployment configuration in minutes. All you need is to edit a couple of files to include modules and set variables. This way you can quickly configure and provision multiple dedicated EKS Kubernetes clusters with different configurations of modules, variables, networks, and Kubernetes versions.

We believe that any developer or organization should be able to focus on their applications without having to worry too much about the nitty-gritty of infrastructure deployment.

Currently, Swiss Army Kube is available for the [Amazon EKS](https://aws.amazon.com/eks/) (Elastic Kubernetes Service) for Kubernetes cluster only. We plan to expand to other platforms soon. 

<br>

## Key Features

### Deploy

* Provision an AWS EKS cluster in minutes
* Use existing project structure to set up your infrastructure
* Configure your deployment in a single `.tfvars` file
* Add and configure modules in a single `.tf` file 
* Deploy with a couple of Terraform commands

### Manage

* Manage your cluster with Terraform and Kubernetes CLI commands
* Easily edit, reconfigure, rerun or destroy resources
* Use handy scripts that make your work faster 

### Scale

* Configure and deploy as many projects as you need fast and easy
* Scale deployments by adding new modules
* Reduce your cloud infrastructure spend with spot instances 
* Maximize your workload cost-efficiency 

<br>

## How it Works

Configure and deploy as many projects as you want. 

1. Sign up for Amazon account
   + Create and configure an IAM user
2. Install Prerequisites
   + Clone this repository
   + Install prerequisites via script (MacOS users) or manually (other users)
   + Rename `example.tfvars` to `terraform.tfvars`
3. Configure your EKS cluster deployment using example directory as a project template
   + Configure modules 
   + Configure variables 
4. Deploy your EKS Kubernetes cluster with Terraform commands
5. Configure `kubectl` to manage your Kubernetes cluster 
6. Manage your EKS Kubernetes cluster and deploy your containerized apps on it
<br>

## Get Started

Visit our [Quickstart](https://github.com/Evanto/qna/wiki/SAK-Quickstart) to install and configure prerequisites, set up your project deployment with desired modules in `modules.tf` and variables in `example.tfvars`, and deploy your infrastructure with Terraform commands:

``` 
terraform init
terraform plan -out plan
terraform apply "plan"
```  

After deployment, manage your cluster with Terraform and Kubernetes CLI commands or AWS management console.
<br>


## Contributing

Contributing to Swiss Army Kube is very welcome. Currently, we're looking for contributions to the documentation of Modules. All you need is being comfortable with GitHub and Git. To get involved with documentation, please read our
[Contributing Guide](https://github.com/Evanto/qna/wiki/SAK-Contributing).
<br>


## License

Swiss Army Kube is licensed under the [Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0.txt).
