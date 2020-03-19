# k8s

![Swiss-army-kube](https://github.com/provectus/swiss-army-kube/raw/poc/logo-swiss-army.png)

## Usage
- Checkout repo
- `cd swiss-army-kube/example` or rename example for your environment name and cd
- Edit terraform.tfvars
- Run `terraform init`
- Run `terraform plan -out=plan` and review
- Run `terraform apply plan`


## Structure
This repository provides the minimal set of resources, which may be required for starting comfortably developing the process of new IaC project:
 - `modules` - Terraform modules.
 - `charts`  - Local helm repository for charts which could not be retrieved from public repositories.
 - `example` - Example project, include some modules and variables for deploy kubernetes EKS and install charts. Use as template.
