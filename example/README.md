# Prerequsite

Helm v2 - `brew install helm@2`

kubectl - `brew install kubernetes-cli`

awscli - `brew install awscli`

terraform - `brew install terraform`

# Structure
  main.tf - data from modules

  modules.tf - list of modules and their redefined values

  providers.tf - list of providers and their values

  variables.tf - variables used in modules

  example.tfvars - list of values for variables. Customize it for your project data !!!

# Deploy cluster
Change example.tfvars, chose modules in main.tf and run:

Prepare and downloads module

`terraform init --upgrade=true`

Plan and test deployment

`terraform plan -var-file=example.tfvars -out plan`

Deploy cluster and helm chart

`terraform apply plan`

## Work with cluster

For destroy some module just remove it from modules.tf and run 

`terraform plan -var-file=example.tfvars -out plan && terraform apply plan`

