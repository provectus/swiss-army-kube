terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket = "dlazarenko-tf-dev-infra-state"
    key    = "global/s3/terraform.tfstate"
    region = "us-west-1"
    # Replace this with your DynamoDB table name!
    #    dynamodb_table = "dlazarenko-tf-dev-infra-locks"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=3.56.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.1.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.1.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
  required_version = ">= 0.14"
}
