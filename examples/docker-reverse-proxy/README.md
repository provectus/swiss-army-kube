# About
That example is the standard deployment of the SAK cluster with managing applications through ArgoCD and setup dockerhub registry proxy to avoid limits.

# How to use

1. Create user

2. Add variables to variables.tf. See example below

```
variable "cluster_name" {
  default = "swiss-army-kube"
}

variable "region" {
  default = "eu-north-1"
}

variable "availability_zones" {
  default = ["eu-north-1a", "eu-north-1b"]
}

variable "zone_id" {
  default = "666"
}

variable "environment" {
  default = "dev"
}

variable "project" {
  default = "EDUCATION"
}

variable "domain_name" {
  default = "edu.provectus.io"
}

variable "argocd" {
  default = {
    repository = "swiss-army-kube"
    branch     = "main"
    owner      = "provectus"
  }
}
```

# Test

* Install rvm

```
curl -sSL https://get.rvm.io | bash -s stable
```

* Install ruby

* Run `bundle install`

* Run `terraform plan && terraform apply`

* Run `AWS_PROFILE=YOUR_PROFILE rake spec`

# Known bugs
### Kubernetes namespace termination stuck

* Run kubectl proxy

* Create json file tmp.json

```
{
    "apiVersion": "v1",
    "kind": "Namespace",
    "metadata": {
        "name": "STUCK_NAMESPACE"
    },
    "spec": {
        "finalizers": []
    }
}
```

* Run `curl -k -H "Content-Type: application/json" -X PUT --data-binary @tmp.json http://127.0.0.1:8001/api/v1/namespaces/STUCK_NAMESPACE/finalize`

### ACM Certificate in state `Pending`

Wait... wait... wait...
