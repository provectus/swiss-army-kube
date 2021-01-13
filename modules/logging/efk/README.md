## Elastic Kibana Filebeat

https://helm.elastic.co/


## Prerequisite

Create Google OAuth keys
First, you need to create a Google OAuth Client:

* Go to https://console.developers.google.com/apis/credentials.
* Click Create Credentials, then click OAuth Client ID in the drop-down menu
* Enter the following:
```
    Application Type: Web Application
    Name: Grafana
    Authorized JavaScript Origins: https://grafana.mycompany.com
    Authorized Redirect URLs: https://grafana.mycompany.com/login/google
    Replace https://grafana.mycompany.com with the URL of your Grafana instance.
```
* Click Create
* Copy the Client ID and Client Secret from the ‘OAuth Client’ modal


## Example how add with module
```
module "efk" {
  module_depends_on = [module.argocd.state.path]
  source            = "../modules/logging/efk"
  cluster_name      = module.kubernetes.cluster_name
  argocd            = module.argocd.state
  efk_oauth2_domain = "auth"
  domains           = local.domain
}
```