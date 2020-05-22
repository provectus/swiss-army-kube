# Prerequsite

Helm v2
`brew install helm@2`
`cd /usr/local/bin`
`ln -s /usr/local/opt/helm@2/bin/tiller tiller`
`ln -s /usr/local/opt/helm@2/bin/helm helm`

kubectl - `brew install kubernetes-cli`

awscli - `brew install awscli`

aws-iam-authenticator - `brew install aws-iam-authenticator`

terraform - `brew install terraform`

# Structure
  main.tf - data from modules

  modules.tf - list of modules and their redefined values

  providers.tf - list of providers and their values

  variables.tf - variables used in modules

  terraform.tfvars - list of values for variables. Customize it for your project data !!!

# Deploy cluster
Change terraform.tfvars, chose modules in main.tf and run:

Prepare and downloads module

`terraform init --upgrade=true`

Plan and test deployment

`terraform plan -out plan`

Deploy cluster and helm chart

`terraform apply plan`

## Work with cluster

For destroy some module just remove it from modules.tf and run 

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
and try `terraform destroy` again