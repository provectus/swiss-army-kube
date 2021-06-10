# Quickstart

## Contents

- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Repository Structure](#repostructure)
- [Adding Developers to the Kubernetes Cluster](#adddevs)
 

## Prerequisites

### Setting up Amazon account and user 

First, you need to have an Amazon account and an IAM user with the "programmatic access" access type. 

* [Amazon AWS](https://aws.amazon.com/)

Create an Amazon account, an IAM user, select your user, create access key on the Security Credentials tab, and make sure you saved your credentials. [Creating an IAM User in Your AWS Account](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html)  

Next, you have to install: 

* [Helm CLI](https://helm.sh/docs/intro/install/)
* [Kubernetes CLI (kubectl)](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [Amazon CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
* [AWS IAM Authenticator for Kubernetes](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
* [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
* [Jq](https://stedolan.github.io/jq/)

### Installing Prerequisites on MacOS

#### Automatic installation on MacOS

For MacOS users this repository has the [prerequisites_install.sh](https://github.com/provectus/swiss-army-kube/blob/master/prerequisites_install.sh) script that will automatically install all the required prerequisites. Clone the repo and run the script:   

``` 
bash swiss-army-kube/prerequisites_install.sh
```  
There is no version of this script for users of other operating systems yet. Non-Mac users should check the link of each prerequisite and install everything manually following instructions.

#### Manual installation on MacOS

Alternatively, you can install the prerequisites manually one by one using Homebrew Cask.

```
$ brew install helm
$ brew install kubernetes-cli
$ brew install awscli
$ brew install aws-iam-authenticator
$ brew install terraform
$ brew install jq
``` 
 
### Installing Prerequisites on Linux

An installation script for Linux users is to be done. At the moment use official guides linked above to install all prerequisites manually. You have to have them installed into the '/usr/local/bin' directory as a result.  

## Usage

### 1. Clone this repository 

Clone this repo if you haven't done it yet: 

``` 
git clone https://github.com/provectus/swiss-army-kube.git
``` 
### 2. Go to the examples/xxx directory

``` 
cd swiss-army-kube/examples/common
```  
The `examples/common` directory contains the common project structure. You can use this folder as is or rename it to your project/environment name for convenience. 

You can use any other example, more detailed instructions for each example can be found in the README of the example

### 3. Configure your EKS cluster 

Edit the `.tf` files to set cluster variables according to your project requirements. Check the [Configure Deployment](./examples/common/CONFIGURE.md) page to learn more. 

A `providers.tf` file contains configuration for Terraform providers, that define how to connect to each platform for working with it such as an AWS cloud or Kubernetes cluster, for example: to change AWS region from _us-west-2_ to another need to modify `region` option of provider `aws`.

A `main.tf` files are consist of modules, each module provides infrastructure things. To add them you can uncomment modules block for specific services, some properties of modules are required, so please follow to module documentation  under `modules` folder for additional information.

### 4. Deploy your pre-configured EKS cluster on Amazon with Terraform commands 

``` 
terraform init
terraform plan -out plan
terraform apply "plan"
```  
* `terraform init` initializes Terraform working directory.
* `terraform plan` generates and shows an execution plan.
* `terraform apply` builds infrastructure or applies changes to it.

Check [Terraform CLI Commands](https://www.terraform.io/docs/commands/index.html) for more info.

### 5. Configure kubectl to manage your Kubernetes cluster 
kubectl is a CLI for Kubernetes cluster management. Make sure that the kubectl client version is within one minor version of your cluster's API server:

```
kubectl version --short
```
Kubectl uses a file named `config` to access Kubernetes clusters. Once you deployed a cluster with Terraform, the `config` file is automatically generated for the cluster in your project directory (`swiss-army-kube/examples/common`). By default, kubectl checks `$HOME/.kube` for the `config` file, so move it there.  

Alternatively, use an environment variable: 
```
export KUBECONFIG=.config:$HOME/.kube/config
```
To view Kubernetes cluster details:
```
kubectl cluster-info
``` 

To view your current cluster configuration (shows merged kubeconfig settings or a specified kubeconfig file):
```
kubectl config view 
```
Check that the deployment succeeded by listing currently deployed pods:
```
kubectl get pods
```

**6. Work with your EKS Kubernetes cluster.**

#### Making changes to Deployment

Apply changes (run after every change of your infrastructure code):

```
terraform plan -out plan
terraform apply plan
```

#### Teardown and Cleanup


To destroy any module: remove it from `main.tf` and run:

```
terraform plan -out plan && terraform apply plan
```

To destroy your EKS cluster: 
  
```
terraform destroy
```

To destroy your EKS cluster with a script ignoring objects that can't be destroyed automatically without manual cleanup (recommended): 

```
bash swiss-army-kube/examples/common/destroy.sh
```

It will ignore Route 53 zone resources, Amazon RDS for Kubeflow, argo-artifacts S3 bucket. Run the script, then destroy these objects manually one by one.

<a name="repostructure"></a>
## Repository Structure

The Swiss Army Kube repository has three main directories that provide a minimal set of resources allowing to comfortably start the development of a new IaC project: 

* `charts`  - local Helm repository for Helm charts that can't be retrieved from public repositories.
* `docs`    - more detailed documentation and various FAQ's
* `examples` - directories with different types of SAK use-cases to be used as a template for your projects that includes configuration files for modules and variables.
* `modules` - Terraform modules (must-have and optional) to deploy your cluster with.

### Project Structure (Example Directory) 

The `swiss-army-kube/examples` directory contains project examples that you can use as boilerplates to start your new projects. Pick one, rename it to your project name for convenience, and modify the directory as required. This way you can create as many projects as you need really fast.

To configure your project cluster for deployment, just [include modules](https://github.com/provectus/sak-incubator) that you need and [set variables](./examples/CONFIGURE.md) in the `.tf` files before deploying your EKS cluster with Terraform commands. 

The `examples/common` directory contains a set of `.tf` files: 

* `main.tf`        - main file with infrastructure code
* `providers.tf`   - list of providers and their values

The `examples/argocd-with-applications` the folder contains an example of deploying infrastructure in aws and applications for cluster operation (like external-dns, prometheus, cluster-autoscaler, etc.)

The `examples/argocd` the folder contains an example of deploying infrastructure in aws and argo-cd server without any applications.

Read about examples and how to use them in the example's README file.


<a name="adddevs"></a>
## Adding Developers to Kubernetes Cluster
 
### DevOps engineer steps

1. Add an IAM user in AWS Console for developer with programmatic access
2. Add user ARN and name to `user_arns` variable with group `system:developers` for _kubernetes_  module in `main.tf` file
3. Run `terraform plan -out=plan` and review
4. Run `terraform apply plan`
5. Send `kubeconfig_internal-projects` config and IAM user tokens to the developer

NOTE: To change developers' permissions on the Kubernetes cluster edit the `cluster_roles` variable in the `main.tf` file.

### Developer steps
1. Configure the AWS CLI with received tokens from DevOps engineer:
 ```
 aws configure --profile your_profile_name
 ```
 NOTE: To use your profile in console run:
 ```
 export AWS_PROFILE=your_profile_name
 ```
2. Use received `kubeconfig_internal-projects` config for running `kubectl` commands
 
 Command examples:
 ```
 kubectl --kubeconfig=kubeconfig_internal-projects get pods --all-namespaces
 kubectl --kubeconfig=kubeconfig_internal-projects port-forward jenkins-xxxx-xxxx 5000:8080 -n jenkins
 ```
