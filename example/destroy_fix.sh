#!/bin/bash

terraform show | grep -e "module.*helm" | tr -d '# :' | xargs terraform state rm
terraform show | grep -e "module.*route53" | tr -d '# :' | xargs terraform state rm

terraform state rm module.nginx.kubernetes_namespace.ingress-system
terraform state rm module.system.kubernetes_namespace.cert-manager