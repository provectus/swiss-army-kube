# EFS CSI driver for K8s

### How to use
``` yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: data-pipelines
  namespace: kubeflow
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  claimRef:
    namespace: kubeflow
    name: efs
  storageClassName: efs-sc
  csi:
    driver: efs.csi.aws.com
    volumeHandle: fs-c326d009
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: efs
  namespace: kubeflow
spec:
  storageClassName: efs-sc
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
```
