# About

That example demonstrates how to configure the EKS cluster with the ArgoCD application. A general idea of the usage of ArgoCD is managing all Kubernetes resources with it. ArgoCD provides us with a way of implementing the GitOps methodology for Kubernetes applications.

## Used modules

- terraform-aws-modules/vpc/aws
- terraform-aws-modules/eks/aws
- github.com/provectus/sak-argocd Does not work with k8s with version 1.22, need to update helm chart

## Implementation

First of all, you execute Terraform commands as it were for `common` example (please follow these instructions to understand how to use SAK). At this step, you will generate all required AWS resources such as EC2 instances, EKS cluster, IAM roles, etc. Also, Terraform will generate a few local files with ArgoCD applications.

The next phase is it uploading these files to your GitHub repository. Please follow ArgoProj's documentation for more detailed information about [how it works](https://argoproj.github.io/argo-cd/#how-it-works)

## NodeGroup types and basic examples
### [General purpose instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/general-purpose-instances.html)
General purpose instances provide a balance of compute, memory, and networking resources, and can be used for a wide range of workloads.

Example
```hcl
general = {
  # expected length of name to be in the range (1 - 38)
  name         = "${local.environment}-${local.cluster_name}"
  max_size     = 3
  desired_size = 1
  bootstrap_extra_args = "${local.default_bootstrap_extra_args} --kubelet-extra-args \"--node-labels=node-type=general,node.kubernetes.io/lifecycle=`curl -s http://169.254.169.254/latest/meta-data/instance-life-cycle`\""

  use_mixed_instances_policy = true
  mixed_instances_policy = {
    instances_distribution = {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 10
      spot_allocation_strategy                 = "capacity-optimized"
    }

    override = [
      {
        instance_type     = "m5.large"
        weighted_capacity = "1"
      },
      {
        instance_type     = "m6i.large"
        weighted_capacity = "2"
      },
    ]
  }
}
```
### [Compute optimized instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/compute-optimized-instances.html)
Compute optimized instances are ideal for compute-bound applications that benefit from high-performance processors.

Example
```hcl
cpu-optimized = {
  # expected length of name to be in the range (1 - 38)
  name         = "${local.environment}-${local.cluster_name}-cpu"
  max_size     = 3
  desired_size = 1
  bootstrap_extra_args = "${local.default_bootstrap_extra_args} --kubelet-extra-args \"--node-labels=node-type=cpu-optimized,node.kubernetes.io/lifecycle=`curl -s http://169.254.169.254/latest/meta-data/instance-life-cycle`\""

  use_mixed_instances_policy = true
  mixed_instances_policy = {
    instances_distribution = {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 10
      spot_allocation_strategy                 = "capacity-optimized"
    }

    override = [
      {
        instance_type     = "c5.large"
        weighted_capacity = "1"
      },
      {
        instance_type     = "c6i.large"
        weighted_capacity = "2"
      },
    ]
  }
}
```
### [Memory optimized instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/memory-optimized-instances.html)
Memory optimized instances are designed to deliver fast performance for workloads that process large data sets in memory.

Example
```hcl
memory-optimized = {
  # expected length of name to be in the range (1 - 38)
  name         = "${local.environment}-${local.cluster_name}-memory"
  max_size     = 3
  desired_size = 1
  bootstrap_extra_args = "${local.default_bootstrap_extra_args} --kubelet-extra-args \"--node-labels=node-type=memory-optimized,node.kubernetes.io/lifecycle=`curl -s http://169.254.169.254/latest/meta-data/instance-life-cycle`\""

  use_mixed_instances_policy = true
  mixed_instances_policy = {
    instances_distribution = {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 10
      spot_allocation_strategy                 = "capacity-optimized"
    }

    override = [
      {
        instance_type     = "r5.large"
        weighted_capacity = "1"
      },
      {
        instance_type     = "r6i.large"
        weighted_capacity = "2"
      },
    ]
  }
}
```
### [Accelerated computing instances(GPU optimized)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/accelerated-computing-instances.html)
If you require high processing capability, you'll benefit from using accelerated computing instances, which provide access to hardware-based compute accelerators such as Graphics Processing Units (GPUs), Field Programmable Gate Arrays (FPGAs), or AWS Inferentia.
- [GPU optimized instance types](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/accelerated-computing-instances.html#gpu-instances)

An instance with an attached NVIDIA GPU, such as a P3 or G4dn instance, must have the appropriate NVIDIA driver installed. Depending on the instance type, you can either download a public NVIDIA driver, download a driver from Amazon S3 that is available only to AWS customers, or use an AMI with the driver pre-installed.
- [Available drivers by instance type](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html#:~:text=for%20video%20decoding-,Available%20drivers%20by%20instance%20type,-The%20following%20table)
- [AMIs with the NVIDIA drivers installed](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html#:~:text=Option%201%3A%20AMIs%20with%20the%20NVIDIA%20drivers%20installed)
- [Public NVIDIA drivers](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html#:~:text=Option%202%3A%20Public%20NVIDIA%20drivers)
- [GRID drivers (G5, G4dn, and G3 instances)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html#:~:text=Option%203%3A%20GRID%20drivers%20(G5%2C%20G4dn%2C%20and%20G3%20instances))
- [NVIDIA gaming drivers (G5 and G4dn instances)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html#:~:text=Option%204%3A%20NVIDIA%20gaming%20drivers%20(G5%20and%20G4dn%20instances))

An instance with an attached AMD GPU, such as a G4ad instance, must have the appropriate AMD driver installed. Depending on your requirements, you can either use an AMI with the driver preinstalled or download a driver from Amazon S3.
- [AMIs with the AMD driver installed](https://aws.amazon.com/marketplace/search/results?searchTerms=AMD+Radeon+Pro+Driver&CREATOR=e6a5002c-6dd0-4d1e-8196-0a1d1857229b&filters=CREATOR)
- [AMD driver download and install](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-amd-driver.html#amd-radeon-pro-software-for-enterprise-driver:~:text=.-,AMD%20driver%20download,-If%20you%20aren%27t)

Example
```hcl
gpu-optimized = {
  # expected length of name to be in the range (1 - 38)
  name         = "${local.environment}-${local.cluster_name}-gpu"
  max_size     = 3
  desired_size = 1
  bootstrap_extra_args = "${local.default_bootstrap_extra_args} --kubelet-extra-args \"--node-labels=node-type=gpu-optimized,node.kubernetes.io/lifecycle=`curl -s http://169.254.169.254/latest/meta-data/instance-life-cycle`\""
  ami_id       = "ami-xxxxxxxxxxxxxxxx" ## Choose ami id with hardware required drivers from aws marketplace(https://aws.amazon.com/marketplace/search)

  use_mixed_instances_policy = true
  mixed_instances_policy = {
    instances_distribution = {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 10
      spot_allocation_strategy                 = "capacity-optimized"
    }

    override = [
      {
        instance_type     = "g4dn.xlarge"
        weighted_capacity = "1"
      }
    ]
  }
}
```
## [Fargate Profiles](https://docs.aws.amazon.com/eks/latest/userguide/fargate.html)
Fargate is a technology that provides on-demand, right-sized compute capacity for containers. With Fargate, you don't have to provision, configure, or scale groups of virtual machines on your own to run containers. You also don't need to choose server types, decide when to scale your node groups, or optimize cluster packing.

Example
```hcl
fargate_profiles = {
  fargate-profile-example = {
    name         = "${local.environment}-${local.cluster_name}-fargate"
    selectors    = [
      {
        namespace = "fargate"
        labels = {
          Application = "fargate-example"
        }
      }
    ]
  }
}
```
## How to use

That example creates a minimal EKS cluster without any additional software except ArgoCD.
You can get KubeConfig for the newly created EKS cluster with the following aws-cli command:
So for access, it needs to establish port forwarding for Kubernetes service, you can do it by the next command:

``` bash
kubectl -n argocd port-forward svc/argocd-server  8080:80
```

Now you can open <http://127.0.0.1:8080> in a browser, the password for accessing ArgoCD UI is stored in AWS System Manager Paramstore, you can retrieve it by command:

``` bash
aws --region <your-region> ssm get-parameter  --with-decryption --name /<your-cluster-name>/argocd/password | jq -r '.Parameter.Value' 
```

### ArgoCD

to get current password:
for the first time use init password ```kubectl get secrets argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -D```

after deploy helm chart:

```bash
kubectl get secret -n argocd argocd-secret -o json | \
  jq '.data|to_entries|map({key, value:.value|@base64d})|from_entries'
```

to set a password:

```bash
kubectl patch secret -n argocd argocd-secret \
  -p '{"stringData": { "admin.password": "'$(htpasswd -bnBC 10 "" newpassword | tr -d ':\n')'"}}'
```
