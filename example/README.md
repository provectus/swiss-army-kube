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

  variables.tf - definition of variables used in modules and their default values

  terraform.tfvars - list of values for variables. **Customize it for your project data!**

# Deploy cluster
Change terraform.tfvars, choose modules in modules.tf and do the following:

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
