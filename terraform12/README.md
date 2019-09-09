# Swiss Army Kube

## What is it ? Reasons

```
Preconfigured templates and modules, terraform and Kubernetes manifests
Infrastructure deployment and lifecycle management should be automated, auditable, and easy to understand.
```

## AWS resources:
- VPC
- VPC peering
- IGW
- Nat Gateway
- Subnets (private,)
- EKS
- Route53
- RDS

## Requirements
- AWS account (programmatic access)
- kubectl
- Terraform 0.12

## How to use
1. Make your own environment configuration file, look at example `environmments/staging/example.main.tf`
2. cd to environment folder
3. run:
  - terraform init
  - terraform plan
  - terraform apply


## Kubernetes system modules
- oauth2
- external-dns
- metrics-server
- sealed-secrets
- ingress-nginx
- cert-manager

## Environments
- global
- management
- staging
- production

### Diagram

