# k8s

![Swiss-army-kube](https://github.com/provectus/swiss-army-kube/raw/poc/logo-swiss-army.png)

## Usage
- Checkout repo
- `cd swiss-army-kube/example` or rename example for your environment name and cd
- Edit terraform.tfvars
- Run `terraform init`
- Run `terraform plan -out=plan` and review
- Run `terraform apply plan`

<<<<<<< HEAD
=======
Preferably make a fork of Provectus repository, but in case this option is not available you may use the following local git repository configuration:
```
git clone git@gitlab.provectus.com:provectus-internals/swiss-army-kube.git project-iac
cd project-iac/
git branch -m master source
git remote rename origin provectus
git checkout -b master
git remote add origin git@gitlab.com:demo-project/project-iac.git
git push -u origin master
git status
git branch
```

This allows using your repository in a regular manner, but saves the ability to receive new features from source repository without directly copying files (all features and advantages of git can be used, eg: branches, merges, etc.)

Also by using this configuration you simplify the process of feature backporting to Provectus repository and decrease the time for review.
>>>>>>> d04e364e6fd08067ee2e00b64eac7c226ab67241

## Structure
This repository provides a minimal set of resources, which may be required to comfortably start developing the process of a new IaC project:
 - `modules` - Terraform modules.
 - `charts`  - Local helm repository for charts which could not be retrieved from public repositories.
 - `example` - Example project, include some modules and variables to deploy kubernetes EKS and install charts. Use as template.
