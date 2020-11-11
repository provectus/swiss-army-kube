# Configure Deployment in example.tfvars

## Contents

1. [Common Variables](#Variables)
2. [Variables of Worker Nodes (Overview)](#nodevars)
3. [Variables of On-Demand Instances](#ondemvars)
4. [Using GPU Instances](#gpunodes)

To configure your cluster with proper parameters before deployment, set variables for your project in the [`main.tf`](https://github.com/provectus/swiss-army-kube/blob/master/examples/common/main.tf) file. It contains variables for all modules in one place, making it easy to set up your configuration quickly and without having to work across multiple separate files for each module.

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
|`cluster_version`      | Provide a version of your EKS cluster. Swiss Army Kube supports EKS versions 1.14, 1.15, and 1.16. Deployments with Kubeflow require EKS 1.15.   |`1.16`
|`cert_manager_email`    | Provide an email to let the cert-manager of your Kubernetes cluster sign up for free [Let’s Encrypt](https://letsencrypt.org/) certificates.|`youremail@domain.com`
|`github-auth`      | You can turn on Ingress Github Oauth 2 authorization to limit who can access your private services and validate users via Github. If `true`, provide `github-client-id`, `github-client-secret`, `cookie-secret`, `github-org`. |`false`
|`google-auth `     | Set to `true` and fill if the block below if you want to use Ingress Google Auth.|`false`
|`elasticDataSize`      | If you use Kibana, provide PersistentVolume storage capacity here.|`30Gi`
|`jenkins_password`     | If you use Jenkins, provide a password here. Uncomment properties below to attach S3 read-only policy for Jenkins IAM roles or add needed policies. |`password`
|`rds_database_name`     | If you use RDS, provide a database name here.|`exampledb`
|`rds_database_engine`   | RDS database engine (aviable postgres mysql oracle-ee sqlserver-ex)| `postgres`
|`rds_database_engine_version`| RDS databese engine version (see versions in AWS RDS engine table)|`9.6.9`
|`rds_database_major_engine_version`| RDS databese major version (AWS bump minor version automatically)|`9`
|`rds_database_instance`| Provide a RDS database instance type|`db.t3.large`
|`rds_database_username`| Provide a RDS database username|`exampleuser`
|`rds_database_password`| Provide a RDS database password| `""`
|`rds_kms_key_id`| Provide a KMS key id if rds_storage_encrypted = true|`""`
|`rds_allocated_storage`| Provide a RDS storage size in GB|`10`
|`rds_storage_encrypted`| If you want encrypted database set true|`false`
|`rds_maintenance_window`| Provide a maintenance window, at this time, the database may be unavailable (the window is set for updating)|`Mon:00:00-Mon:03:00`
|`rds_backup_window`| Provide a backup window, at this time, the database may be unavailable (the window is set for creating backups)|`03:00-06:00`
|`rds_database_multi_az`| If you want use multi aviability zone mode, set true.This will require an additional fee|`true`
|`rds_database_delete_protection`| Delete protection mode, set true if you want prevent delete RDS|`false`
|`rds_database_tags`| Additionals tags for RDS instance, comma separate key=value pairs|`{ "test" = "tags" }`
|`airflow_username`| Provide a Airflow username here.|`username`
|`airflow_password`| Provide a Airflow password here. If password null it's autogenerate and store to AWS ParamStore|`""`
|`airflow_fernetKey`| Generate fernetKey (read about https://bcb.github.io/airflow/fernet-key )|`GFqrDfu-0oac6x2ATKLsx-Mr2yHKWFpa5hY4pYeWmXw=`
|`airflow_postgresql_local`| Set true if you want use local postgresql database (pod in kubernetes).|`true`
|`airflow_postgresql_host`| Provide postgresql host, if you set airflow_postgresql_local to false|`""`
|`airflow_postgresql_port`| Provide postgresql port, if you set airflow_postgresql_local to false|`5432`
|`airflow_postgresql_username`| Provide a postgresql username here.|`postgresqluser`
|`airflow_postgresql_password`| Provide a postgresql password here.If password null it's autogenerate and store to AWS ParamStore|`""`
|`airflow_postgresql_database`| Provide a postgresql database name here.|`airflow`
|`airflow_redis_local`| Set true if you want use local redis database (pod in kubernetes).|`true`
|`airflow_redis_host`| Provide redis host, if you set airflow_redis_local to false|`""`
|`airflow_redis_port`| Provide redis port, if you set airflow_redis_local to false|`6379`
|`airflow_redis_username`| Provide a redis username here.|`redisuser`
|`airflow_redis_password`| Provide a redis password here.|`""`

<a name="nodevars"></a>
## Variables of Worker Nodes (EC2 Instances)
 
Use this block of variables to set up the type, number, and other parameters of your EC2 instances for the following node types:

1. Common - On-Demand EC2 instances
2. CPU - CPU-focused EC2 instances 
3. GPU - GPU-focused EC2 instances


**On-Demand (Common) Instances**

With On-Demand instances, you pay for instances that you launch per hour or second, on a fixed-price basis. 
Unlike Spots, on-demand instances are stable and won't disappear out of the blue. 
We recommend, that at least 30% of your cluster consist of on-demand instances as the best practice. 

* [On-Demand Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-on-demand-instances.html)
* [Amazon EC2 On-Demand Pricing](https://aws.amazon.com/ec2/pricing/on-demand/)

**Spot Instances** 

Spot instances are a spare capacity that AWS sells at up to 90% discount. Using them allows you to save money by optimizing workload costs. The downside is that Spots are not guaranteed to stay available and can be recalled by AWS at any time. The more spots you use in an EKS cluster, the more risk exists for your cluster to suddenly become unavailable.  

If you want use spot instance, set on_demand_common_percentage_above_base_capacity in percent. When set 30%, it's means that 70% instance in ASG common will be spot instance.

**CPU Instances**

Amazon EC2 C instances with high-performance processors. CPU instances are critical for resource-intensive tasks like scientific modeling, machine learning inference, and other compute-intensive apps.  

* [Amazon EC2 Compute Optimized Instances](https://aws.amazon.com/ec2/instance-types/#Compute_Optimized)
 
**GPU Instances** 

Amazon EC2 P instances with high-performance processors. GPU instances use hardware accelerators, or co-processors, to perform functions more efficiently than is possible in software running on CPUs. GPUs are often used by data scientists to calculate ML models, perform functions, process graphics, etc. 

* [Amazon EC2 Accelerated Computing Instances](https://aws.amazon.com/ec2/instance-types/#Compute_Optimized)

All nodes of a cluster are labeled with node type (Common, GPU, CPU). When you deploy an app, you can use Kubernetes tools to specify which group of nodes to deploy this particular app to.

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
|`on_demand_common_percentage_above_base_capacity `  | Controls the percentage of the add-on to the initial group that is made up of on-demand EC2 Instances versus the percentage that is made up of Spot Instances.|`100`
|`on_demand_common_asg_recreate_on_change`        	| When true, recreates an ASG group if changes have been made. |`true`

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
