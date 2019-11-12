```shell script
helm init
kubectl apply -f rbac-full-access.yml
kubectl --namespace kube-system patch deploy tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
```

See https://github.com/helm/helm/issues/5100 for explanation of errors while installing helm.
See https://helm.sh/docs/rbac/#role-based-access-control for detailed production-grade configuration.
