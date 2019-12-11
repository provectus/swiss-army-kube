# Annotation
The Kubernates module is used to deploy the EKS cluster in Amazon. Also creates an autoscaling group in selected accessibility zones

## Used modules

- [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks)
- [terraform-aws-vpc](https://github.com/terraform-aws-modules/terraform-aws-vpc)

## Feature

- `Spot or on_demand workers` - node-labels=kubernetes.io/lifecycle=normal for on_demand node and node-labels=kubernetes.io/lifecycle=spot for spot node. Your make use it for [Node affinity](https://kubernetes.io/docs/concepts/configuration/assign-pod-node)
- `Add arns for additional admins` - We set current user to add as admin EKS cluster. Your make add additional admins arn's to variables admin_arns in variables.tf or module parameters in project