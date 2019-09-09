# Swiss Army Kube

![](https://raw.githubusercontent.com/provectus/swiss-army-kube/749c8bc2ddb0fb16e394dbc0b46e46f753ecb9db/logo.png?token=AC2LBA4XETSMFM64IMX2H3S5P74GC)

Swiss Army Kube lets you deploy essential AWS services in a hassle-free manner via a simple yet powerful configuration of Terraform and Kubernetes manifests. You can pick preconfigured templates and modules and deploy your infrastructure, that is automated, auditable, and easy to understand.

## Supports following AWS services
- VPC
- VPC peering
- IGW
- Nat Gateway
- Subnets (private & public)
- EKS
- Route53
- RDS

## Requirements
- AWS account (programmatic access)
- kubectl
- Terraform 0.12

## How to use
1. Make your environment configuration file, look at the following example `environments/staging/example.main.tf`
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

