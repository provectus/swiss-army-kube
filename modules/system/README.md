# System
A module to configure EKS cluster:

- `cert-manager` - official [documentation](https://github.com/helm/charts/tree/master/stable/cert-manager)
- `external-dns` - official [documentation](https://github.com/helm/charts/tree/master/stable/external-dns)
- `saled-secrets` - official [documentation](https://github.com/helm/charts/tree/master/stable/sealed-secrets)
- `kube-state-metrics` - official [documentation](https://github.com/helm/charts/tree/master/stable/kube-state-metrics)


# Feature

-  `Assign IAM Permissions to Kubernetes Service Accounts` -  [documentation](
https://aws.amazon.com/ru/about-aws/whats-new/2019/09/amazon-eks-adds-support-to-assign-iam-permissions-to-kubernetes-service-accounts)

# Warning
```
      resources:
        limits:
          nvidia.com/gpu: 2 # requesting 2 GPUs
```          
WARNING: if you don't request GPUs when using the device plugin with NVIDIA images all the GPUs on the machine will be exposed inside your container.

# TODO

- Add NS records to main dns zone for created domain
