## Extra documentation, tips and hacks


### Recreate IP address of NAT gateway (not seamlessly)

Sometimes public IP address appears in blacklist of some services (e.g https://infra.apache.org/infra-ban.html).
To avoid that - is good to prevent abuse such services using artifact caching servers such as Nexus, Artifactory, etc (if they have their own public IP)
If there is still need to have direct access - it's time to just recreate IP.

In `swiss-army-kube/example` (or `swiss-army-kube/<environment name>`):

```shell
terraform destroy -target 'module.network.module.vpc.aws_eip.nat[0]'
terraform apply -target module.network.module.vpc
```

This method is suitable when short absence of access from VPC to internet is affordable (e.g during maintenance)