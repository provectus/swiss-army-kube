# Prerequsite

Helm v2
```
brew install helm@2
```
kubectl
```
brew install kubernetes-cli
```
awscli
```
brew install awscli
```
terraform
```
brew install terraform
```

# Structure
  main.tf - 
  modules.tf - list of modules and their redefined values
  providers.tf - list of providers and their values
  variables.tf - variables used in modules
  example.tfvars - list of values for variables

# Deploy cluster
Change example.tfvars, chose modules in main.tf and run:

Prepare and downloads module
`terraform init --upgrade=true`

Plan and test deployment
`terraform plan -var-file=example.tfvars`

Deploy cluster and helm chart
`terraform apply -var-file=example.tfvars`

## Work with cluster

For destroy some module just remove it from modules.tf and run 
` terraform apply -var-file=example.tfvars `