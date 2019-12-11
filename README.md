# k8s
## Usage

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

## Structure
This repository provides the minimal set of resources, which may be required for starting comfortably developing the process of new IaC project:
 - `modules` - Terraform modules.
 - `charts`  - Local helm repository for charts which could not be retrieved from public repositories.
 - `example` - Example project, include some modules and variables for deploy kubernetes EKS and install charts. Use as template.
