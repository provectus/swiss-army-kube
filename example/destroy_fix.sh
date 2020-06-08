#!/bin/bash

terraform state list | grep -e "module.*helm" | xargs terraform state rm
terraform state list | grep -e "module.*route53" | xargs terraform state rm

terraform state rm module.nginx.kubernetes_namespace.ingress-system
terraform state rm module.system.kubernetes_namespace.cert-manager