# Examples of use SAK
## Known particular qualities of operation
### Usage of GPU nodes
NVIDIA GPUs can be consumed via container level resource requirements using the resource name nvidia.com/gpu:
``` yaml
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
__WARNING__: if you don't request GPUs when using the device plugin with NVIDIA images all the GPUs on the machine will be exposed inside your container.
### Hanging of Kubernetes namespaces on the deletion
For some reason (unmanaged K8s resources, a large set of resources, etc), deletion of the Kubernetes namespace can take a while. In case of entire cluster destroying you could resolve this by manual deletion of resources from Terraform state, for example:
``` bash
terraform state list | grep kubernetes_namespace | xargs terraform state rm {}
```