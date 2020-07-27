#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

terraform destroy -auto-approve
RESULT=$?

if [ $RESULT -ne 0 ]; then
    terraform state list | grep -e "module.*helm" | xargs terraform state rm
    terraform state list | grep -e "module.*route53" | xargs terraform state rm

    terraform state rm module.nginx.kubernetes_namespace.ingress-system
    terraform state rm module.system.kubernetes_namespace.cert-manager

    terraform state rm module.argo-artifacts.aws_s3_bucket.argo-artifacts

    terraform state rm module.nginx.kubernetes_secret.oauth2-proxy-secret-google
    terraform state rm module.nginx.kubernetes_secret.oauth2-proxy-secret

    case "$OSTYPE" in
      darwin*)  sed -i "" 's/\"skip_final_snapshot\":.*/\"skip_final_snapshot\": true,/g' "$SCRIPTPATH/terraform.tfstate" ;;
      linux*)   sed -i 's/\"skip_final_snapshot\":.*/\"skip_final_snapshot\": true,/g' "$SCRIPTPATH/terraform.tfstate" ;;
    esac

    terraform destroy -auto-approve
fi