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


## Use GPU nodes

NVIDIA GPUs can now be consumed via container level resource requirements using the resource name nvidia.com/gpu:

```
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  containers:
    - name: cuda-container
      image: nvidia/cuda:9.0-devel
      resources:
        limits:
          nvidia.com/gpu: 2 # requesting 2 GPUs
    - name: digits-container
      image: nvidia/digits:6.0
      resources:
        limits:
          nvidia.com/gpu: 2 # requesting 2 GPUs
```          
WARNING: if you don't request GPUs when using the device plugin with NVIDIA images all the GPUs on the machine will be exposed inside your container.

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