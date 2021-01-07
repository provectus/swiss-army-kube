## Elastic Kibana Filebeat

https://helm.elastic.co/

## Example how add with module
```
module "efk" {
  module_depends_on = [module.argocd.state.path]
  source            = "../modules/logging/efk"
  cluster_name      = module.kubernetes.cluster_name
  argocd            = module.argocd.state
  efk_oauth2_domain = ""
  domains           = local.domain
}
```