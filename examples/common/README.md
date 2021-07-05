# About

simple installation of EKS and VPC


# Prerequisites

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

# Structure
  main.tf - the main Terraform file with infrastructure code

  providers.tf - list of providers and their values

# Deploy cluster
Change variables.tf, choose modules in main.tf and do the following:

Prepare and download modules

`terraform init --upgrade=true`

Plan and test deployment

`terraform plan -out plan`

Review plan if needed

`terraform show plan`

Deploy cluster and helm charts

`terraform apply plan`

## Working with cluster

To destroy some module just remove them from modules.tf and run 

`terraform plan -out plan && terraform apply plan`


## Troubleshooting
Enable terraform logs verbose
`export TF_LOG=trace`

Remove corrupt state 
`terraform state rm module.loki.helm_release.loki-stack`

Refresh tfstate
`terraform refresh -var-file example.tfvars`

Recreate resources
`terraform taint module.system.null_resource.helm_init`

If `terraform destroy` command fails, run
`destroy_fix.sh`
and try `terraform destroy` again. After successful destroy process go to AWS console and delete argo-artifacts S3 bucket (if needed), also delete Route53 resources remaining from your deployment.