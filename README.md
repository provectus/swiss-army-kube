# k8s

## Workstation setup

For most operations with Kubernetes you will need the following CLI tools installed on your laptop:

`aws-iam-authenticator` is required installed before you create your EKS cluster with Terraform:
```shell script
brew install aws-iam-authenticator  # only for AWS-based setups
```

`kubectl` and `helm` are commonly used in day to day operations of k8s
```shell script
brew install kubernetes-cli         # kubectl command
brew install kubernetes-helm        # helm command
```

After creation of cluster connect to it using the following command (put in your params accordingly):

```
aws eks --region eu-west-2 update-kubeconfig --name timurb-cluster
```

FIXME: IAM-kubernetes mappings might be disabled. Put here snippet for reusing IAM mappings with `aws-iam-authenticator`.

For Helm installation check [this document](scripts/helm/README.md)

## Structure
This repository provides the minimal set of resources, which may be required for starting comfortably developing the process of new IaC project:
 - `modules` - Terraform modules
 - `charts` - local helm repository for charts which could not be retrieved from public repositories

## Reuse

Preferably make a fork of Provectus repository, but in case of unavailability of this variant may use the next local git repository configuration:
```
git clone git@github.com:provectus/swiss-army-kube.git project-iac
cd project-iac/
git branch -m master source
git remote rename origin provectus
git checkout -b master
git remote add origin git@gitlab.com:demo-project/project-iac.git
git push -u origin master
git status
git branch
```

This allows using your repository in a normal manner, but save the ability to receive new features from source repository without directly files copying (all features and advantages of git could be used, ef: branches, merges, etc.)

Also by using this configuration you simplify the process of feature backporting to Provectus repository and decrease the time for review.

