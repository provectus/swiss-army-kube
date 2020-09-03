# Configure Deployment in example.tfvars

## Contents

1. [Common Variables](#Variables)
2. [Variables of Worker Nodes (Overview)](#nodevars)
3. [Variables of On-Demand Instances](#ondemvars)
4. [Variables of Spot Instances](#spotvars)
5. [Using GPU Instances](#gpunodes)

Terraform's `.tfvars` files are used to manage AWS environments. While variables are defined in the `.tf` files, their inputs are provided in the `.tfvars` variable definitions file that uses the same basic syntax as Terraform language files but consists only of variable name assignments and comments.

To configure your cluster with proper parameters before deployment, set variables for your project in the [`.tfvars` file](./example/example.tfvars). It contains variables for all modules in one place, making it easy to set up your configuration quickly and without having to work across multiple separate files for each module.

<a name="variables"></a>
## Common Variables

|Name               	|Description                    |Default / Example
|-----------------------|-------------------------------|-------------------------------
|`aws_region`           | Name of your AWS region. Regions are physical locations where clusters of Amazon data centers are located. |`us-west-2`
|`aws_private` 	        | Deployment in either private (`true`) or public (`false`) mode.|`false`
|`availability_zones` 	| Unique name of AWS cluster or several clusters. Each group of logical AWS data centers is called Availability Zone. | `"us-west-2b", "us-west-2a", "us-west-2c"`
|`cluster_name`   	| Unique name of your Kubernetes cluster. | `yourclustername`
|`environment`          | Environment name tag for convenient search and identification of objects across your clusters. | `dev`
|`project`        	| Project name tag for convenient search and identification of objects across your clusters. |`yourprojectname`
|`mainzoneid`        	| Main Route 53 domain zone ID to let Terraform automatically add NS and SOA records to the root domain.|`Z02149423PVQ0YMP19F13`
|`domains`        	| Your domain name or an array of domain names with the first being the main Ingress FQDN (Fully Qualified Domain Name) to create Route53 hosting zone and Kubernetes Ingress. |`swiss-army.edu.provectus.io`
|`config_path`        	| Unique path to the Kubernetes configuration file for working with your EKS clusters. The configuration file is located in the `swiss-army-kube/example` directory. |`kubeconfig_projectname`
|`network`        	| Set a subnet your cluster will work in by providing a number to be as used "x" in the 10.X.0.0/16 CIDR template. Normally the default is enough, but you can change it once you have complex installations that require other subnets.  |`10`
|`admin_arns`        	| Provide AWS IAM credentials (`userarn`, `username`, `groups`) of administrators of your Kubernetes cluster. Add as many administrators as you want by adding arrays.|`arn:aws:iam::245582572290:user/username`, `username`, `system:masters`
|`cluster_version`      | Provide a version of your EKS cluster. Swiss Army Kube supports EKS versions 1.14, 1.15, and 1.16. Deployments with Kubeflow require EKS 1.15.   |`1.15`
|`cert_manager_email`    | Provide an email to let the cert-manager of your Kubernetes cluster sign up for free [Let’s Encrypt](https://letsencrypt.org/) certificates.|`youremail@domain.com`
|`github-auth`      | You can turn on Ingress Github Oauth 2 authorization to limit who can access your private services and validate users via Github. If `true`, provide `github-client-id`, `github-client-secret`, `cookie-secret`, `github-org`. |`false`
|`google-auth `     | Set to `true` and fill if the block below if you want to use Ingress Google Auth.|`false`
|`elasticDataSize`      | If you use Kibana, provide PersistentVolume storage capacity here.|`30Gi`
|`jenkins_password`     | If you use Jenkins, provide a password here. Uncomment properties below to attach S3 read-only policy for Jenkins IAM roles or add needed policies. |`password`
|`grafana_password`     | If you use Grafana, provide a password here. To enable Google Auth for Grafana, uncomment and fill the block below (`grafana_google_auth`, `grafana_client_id`, `grafana_client_secret`, `grafana_allowed_domains`).  |`password`

<a name="nodevars"></a>
## Variables of Worker Nodes (EC2 Instances)
 
Use this block of variables to set up the type, number, and other parameters of your EC2 instances for the following node types:

1. Common - On-Demand EC2 instances (stable, more expensive)
2. Spot - Spot EC2 instances (unstable, less expensive)
3. CPU - CPU-focused EC2 instances 
4. GPU - GPU-focused EC2 instances


**On-Demand (Common) Instances**

With On-Demand instances, you pay for instances that you launch per hour or second, on a fixed-price basis. 
Unlike Spots, on-demand instances are stable and won't disappear out of the blue. 
We recommend, that at least 30% of your cluster consist of on-demand instances as the best practice. 

* [On-Demand Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-on-demand-instances.html)
* [Amazon EC2 On-Demand Pricing](https://aws.amazon.com/ec2/pricing/on-demand/)

**Spot Instances** 

Spot instances are a spare capacity that AWS sells at up to 90% discount. Using them allows you to save money by optimizing workload costs. The downside is that Spots are not guaranteed to stay available and can be recalled by AWS at any time. The more spots you use in an EKS cluster, the more risk exists for your cluster to suddenly become unavailable.  

**CPU Instances**

Amazon EC2 C instances with high-performance processors. CPU instances are critical for resource-intensive tasks like scientific modeling, machine learning inference, and other compute-intensive apps.  

* [Amazon EC2 Compute Optimized Instances](https://aws.amazon.com/ec2/instance-types/#Compute_Optimized)
 
**GPU Instances** 

Amazon EC2 P instances with high-performance processors. GPU instances use hardware accelerators, or co-processors, to perform functions more efficiently than is possible in software running on CPUs. GPUs are often used by data scientists to calculate ML models, perform functions, process graphics, etc. 

* [Amazon EC2 Accelerated Computing Instances](https://aws.amazon.com/ec2/instance-types/#Compute_Optimized)

All nodes of a cluster are labeled with node type (Common, Spot, GPU, CPU). When you deploy an app, you can use Kubernetes tools to specify which group of nodes to deploy this particular app to.

* [Check all Amazon EC2 Instance Types.](https://aws.amazon.com/ec2/instance-types/)

<a name="ondemvars"></a>
### Variables of On-Demand EC2 Instances
|Name               	|Description                    |Default / Example
|-----------------------|-------------------------------|-------------------------------
|`on_demand_common_max_cluster_size` | Maximum number of nodes in a cluster |`5`
|`on_demand_common_min_cluster_size ` 	| Minimum number of nodes in a cluster |`1`
|`on_demand_common_desired_capacity` 	| How many nodes will get started |`2`
|`on_demand_common_instance_type`   	| Amazon EC2 instance types in order of priority|`"m5.large", "m5.xlarge", "m5.2xlarge"`
|`on_demand_common_allocation_strategy`  | Allocation strategy that will define priority and number of different on-demand EC2 instance types in your cluster. Valid values: `prioritized`. |`prioritized`
|`on_demand_common_base_capacity`        | Percent of EC2 instances of this type in a cluster. Controls how much of the initial cluster capacity is made up of Common on-demand EC2 instances. Set to 0 indicates that you prefer to launch them as a percentage of the total group capacity that is running at any given time.    |`0`
|`on_demand_common_percentage_above_base_capacity `  | Controls the percentage of the add-on to the initial group that is made up of on-demand EC2 Instances versus the percentage that is made up of Spot Instances.|`0`
|`on_demand_common_asg_recreate_on_change`        	| When true, recreates an ASG group if changes have been made. |`true`

<a name="spotvars"></a>
### Variables of Spot EC2 Instances
Spot instances have all the same variables as on-demand instances do, but also have two more additional ones listed below. 

|Name               	|Description                    |Default / Example
|-----------------------|-------------------------------|-------------------------------
|`spot_instance_pools` | Number of Spot pools per availability zone to allocate capacity. EC2 Auto Scaling selects the cheapest Spot pools and evenly allocates Spot capacity across the number of Spot pools that you specify. |`10`
|`spot_max_price` | Maximum price per unit hour that the user is willing to pay for the Spot instances. Default: an empty string which means the on-demand price. |` `

<a name="gpunodes"></a>
## Using GPU Instances 

NVIDIA GPUs can now be consumed via container level resource requirements using the resource name `nvidia.com/gpu`:
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
WARNING: 

If you don't request GPUs when using the device plugin with NVIDIA images, all the GPUs on the machine will be exposed inside your container.
