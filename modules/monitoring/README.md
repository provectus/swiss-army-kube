# System
A module to configure EKS cluster:

```
helm upgrade --install aws-cluster-autoscaler  stable/cluster-autoscaler --set autoDiscovery.clusterName=sak-cluster --set rbac.create=true --set rbac.pspEnabled=true --set awsRegion=us-east-1
```
