# k8s 

![Swiss-army-kube](https://github.com/provectus/swiss-army-kube/raw/master/logo-swiss-army.png)

## Prerequisites

#### Helm v3  
`brew install helm`

#### kubectl  
`brew install kubernetes-cli`

#### awscli  
`brew install awscli`

#### aws-iam-authenticator  
`brew install aws-iam-authenticator`

#### terraform  
`brew install terraform`

#### kfctl 
`bash swiss-army-kube/kfctl_install.sh`

( To run kfctl, go to the `/usr/local/bin/kfctl` binary file in Finder, right-click, then select Open. Then click Open again to confirm that you want to open the app. )  

#### jq
`brew install jq`

#### To install all prerequisites
`bash swiss-army-kube/prerequisites_install.sh` 

## Usage
- Checkout repo
- `cd swiss-army-kube/example` or rename "example" for your environment name and `cd swiss-army-kube/<environment name>`
- `mv example.tfvars terraform.tfvars`
- Edit terraform.tfvars (for security reasons terraform.tfvars in .gitignore)
- Run `terraform init`
- Run `terraform plan -out=plan` and review
- Run `terraform apply plan`

## Structure
This repository provides a minimal set of resources, which are helpful to comfortably start development of a new IaC project:
 - `modules` - Terraform modules.
 - `charts`  - Local helm repository for charts which could not be retrieved from public repositories.
 - `example` - Example project, include some modules and variables to deploy AWS EKS and install charts. Use as a template.
 
 
 ## Adding developers to k8s cluster
 #### DevOps engineer steps
 - Add IAM user in AWS Console for developer with programmatic access
 - Add user arn and name to `user_arns` variable with group `system:developers` in `terraform.tfvars` file
 - Run `terraform plan -out=plan` and review
 - Run `terraform apply plan`
 - Send `kubeconfig_internal-projects` config and IAM user tokens to developer
 
 NOTE: To change developers permissions on k8s cluster manipulate `cluster_roles` variable in `terraform.tfvars` file
 
 #### Developer steps
 - Configure the AWS CLI with received tokens from DevOps engineer:
 ```
 aws configure --profile your_profile_name
 ```
 NOTE: To use your profile in console run:
 ```
 export AWS_PROFILE=your_profile_name
 ```
 - Use received `kubeconfig_internal-projects` config for running `kubectl` commands
 
 Command examples:
 ```
 kubectl --kubeconfig=kubeconfig_internal-projects get pods --all-namespaces
 kubectl --kubeconfig=kubeconfig_internal-projects port-forward jenkins-xxxx-xxxx 5000:8080 -n jenkins
 ```