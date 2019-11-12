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

## Links

* Detailed production-grade configuration: https://helm.sh/docs/rbac/#role-based-access-control
* One more article on how to configure Tiller properly https://medium.com/@elijudah/configuring-minimal-rbac-permissions-for-helm-and-tiller-e7d792511d10
* Explanation of some errors while installing helm: https://github.com/helm/helm/issues/5100

