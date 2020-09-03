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
* [Kubeflow CLI (kfctl)](https://www.kubeflow.org/docs/aws/deploy/install-kubeflow/)
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
$ bash swiss-army-kube/kfctl_install.sh
$ brew install jq
``` 

The [kfctl_install.sh](https://github.com/provectus/swiss-army-kube/blob/master/kfctl_install.sh) script installs kfctl. To run kfctl, go to the `/usr/local/bin/kfctl` binary file in Finder, right-click and select Open. Then click Open again to confirm that you want to open the app.  
 
### Installing Prerequisites on Linux

An installation script for Linux users is to be done. At the moment use official guides linked above to install all prerequisites manually. You have to have them installed into the '/usr/local/bin' directory as a result.  

## Usage

### 1. Clone this repository 

Clone this repo if you haven't done it yet: 

``` 
git clone https://github.com/provectus/swiss-army-kube.git
``` 
### 2. Go to the example directory

``` 
cd swiss-army-kube/example
```  
The `example` directory contains the project structure. You can use this folder as is or rename it to your project/environment name for convenience. 

### 3. Configure your EKS cluster 

Edit the [`.tfvars` file](./example/example.tfvars) to set cluster variables according to your project requirements. Check the [Configure Deployment](./example/CONFIGURE.md) page to learn more. 

### 4. Deploy your pre-configured EKS cluster on Amazon with Terraform commands 

``` 
terraform init
terraform plan -var-file=example.tfvars -out plan
terraform apply "plan"
```  
* `terraform init` initializes Terraform working directory.
* `terraform plan` generates and shows an execution plan.
* `terraform apply` builds infrastructure or applies changes to it.
* `terraform plan -var-file=example.tfvars -out plan` tells Terraform to use the `example.tfvars` file to source variables. 

Check [Terraform CLI Commands](https://www.terraform.io/docs/commands/index.html) for more info.

#### Making Terraform Automatically Recognize the Variables Definition File (Optional)

By default, Terraform tries to find your variables in the file named `terraform.tfvars`. However, in the Swiss Army Kube repository, you  have the `example.tfvars` file instead (because for security reasons, `terraform.tfvars` is in `.gitignore`). That's why in the previous step, we explicitly pointed Terraform what file to use with the `-var-file=example.tfvars` part of the `terraform plan -var-file=example.tfvars -out plan` command. If you want Terraform to start recognizing and using the proper variables file automatically, do the steps below.  

1. Run `mv example.tfvars terraform.tfvars` to rename the `example.tfvars` file to `terraform.tfvars` 

2. Each time you edit `terraform.tfvars` to set your deployment configuration, run `terraform plan -out plan` to apply it instead of `terraform plan -var-file=example.tfvars -out plan`.  

### 5. Configure kubectl to manage your Kubernetes cluster 
kubectl is a CLI for Kubernetes cluster management. Make sure that the kubectl client version is within one minor version of your cluster's API server:

```
kubectl version --short
```
Kubectl uses a file named `config` to access Kubernetes clusters. Once you deployed a cluster with Terraform, the `config` file is automatically generated for the cluster in your project directory (`swiss-army-kube/example`). By default, kubectl checks `$HOME/.kube` for the `config` file, so move it there.  

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

Apply changes (run after every change of your infrastructure in `example.tfvars`):

```
terraform plan -out plan
terraform apply plan
```


#### Teardown and Cleanup


To destroy any module: remove it from `modules.tf` and run:

```
terraform plan -out plan && terraform apply plan
```

To destroy your EKS cluster: 
  
```
terraform destroy -var-file=example.tfvars
```

To destroy your EKS cluster with a script ignoring objects that can't be destroyed automatically without manual cleanup (recommended): 

```
bash swiss-army-kube/example/destroy.sh
```

It will ignore Route 53 zone resources, Amazon RDS for Kubeflow, argo-artifacts S3 bucket. Run the script, then destroy these objects manually one by one.

<a name="repostructure"></a>
## Repository Structure

The Swiss Army Kube repository has three main directories that provide a minimal set of resources allowing to comfortably start the development of a new IaC project: 

* `charts`  - local Helm repository for Helm charts that can't be retrieved from public repositories.
* `example` - directory to be used as a template for your projects that includes configuration files for modules and variables.
* `modules` - Terraform modules (must-have and optional) to deploy your cluster with.

### Project Structure (Example Directory) 

The `swiss-army-kube/example` directory is a boilerplate for your projects. Use it as a template. You can rename it to your project name for convenience. Make as many projects as you need by cloning and modifying this directory.  

To configure your project cluster for deployment, just [include modules](https://github.com/provectus/swiss-army-kube/tree/master/modules) that you need and [set variables](https://github.com/provectus/swiss-army-kube/blob/master/example/CONFIGURE.md) in the [`.tfvars` file](https://github.com/provectus/swiss-army-kube/blob/master/example/example.tfvars) before deploying your EKS cluster with Terraform commands. 

The example directory contains a set of `.tf` files: 

* `main.tf`        - data from modules
* `modules.tf`     - a list of modules and their redefined values
* `output.tf`      - contains ouput definitions for your modules
* `providers.tf`   - list of providers and their values
* `variables.tf`   - definition of variables used in modules and their default values
* `example.tfvars` - (rename into `terraform.tfvars` for convenience) - list of values for variables that you modify. 

<a name="adddevs"></a>
## Adding Developers to Kubernetes Cluster
 
### DevOps engineer steps

1. Add an IAM user in AWS Console for developer with programmatic access
2. Add user ARN and name to `user_arns` variable with group `system:developers` in `terraform.tfvars` file
3. Run `terraform plan -out=plan` and review
4. Run `terraform apply plan`
5. Send `kubeconfig_internal-projects` config and IAM user tokens to the developer

NOTE: To change developers permissions on Kubernetes cluster manipulate `cluster_roles` variable in the `terraform.tfvars` file.
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
