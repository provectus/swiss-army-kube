# Helm installation

To start using Helm you need to initialize it in K8s cluster:
 1. Install Tiller (server-side Helm component)
 2. Create policy for it to access K8s
 3. Attach policy to its deployment



```shell script
helm init
### WARNING: the below line is not for production use
### See comment below this snippet
kubectl apply -f rbac-full-access.yml
kubectl --namespace kube-system patch deploy tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
```
This snippet configures Tiller with full cluster access.
For production setups reduced privileges are recommended.

See https://helm.sh/docs/rbac/#role-based-access-control for detailed production-grade configuration.

See https://github.com/helm/helm/issues/5100 for explanation of some errors while installing helm.

