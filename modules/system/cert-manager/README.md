# Cert-manager

## How it use

```
module "cert-manager" {
  depends_on   = [module.clusterwide]
  source       = "../modules/system/cert-manager"
  cluster_name = module.kubernetes.cluster_name
  argocd       = module.argocd.state
  email        = "cert@example.com"
  hostedZoneID = module.external_dns.zone_id
  domain       = var.domain_name
  conf = {}
  tags = local.tags

}
```