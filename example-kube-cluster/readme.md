# Prerequsite

Helm v2.16
```
xcode-select --install
brew install https://github.com/Homebrew/homebrew-core/raw/63cef9dba3efc5e5cb03dddd9eeae5ea52dee066/Formula/kubernetes-helm.rb
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

# Deploy cluster
Change example.tfvars, chose modules in main.tf and run:
Prepare and downloads module
`terraform init`

Plan and test deployment
`terraform plan -var-file=example.tfvars`

Deploy cluster and helm chart
`terraform apply -var-file=example.tfvars`
