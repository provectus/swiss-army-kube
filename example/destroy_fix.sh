#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# Workaround for failure of removing Route53 hosted zones
terraform state list | grep -e "module.*helm" | xargs terraform state rm
terraform state list | grep -e "module.*route53" | xargs terraform state rm

terraform state rm module.nginx.kubernetes_namespace.ingress-system
terraform state rm module.system.kubernetes_namespace.cert-manager

# Workaround for non-empty s3 bucket
terraform state rm module.argo-artifacts.aws_s3_bucket.argo-artifacts

# Workaround for "Error: RDS Cluster FinalSnapshotIdentifier is required when a final snapshot is required"
case "$OSTYPE" in
  darwin*)  sed -i "" 's/\"skip_final_snapshot\":.*/\"skip_final_snapshot\": true,/g' "$SCRIPTPATH/terraform.tfstate" ;;
  linux*)   sed -i 's/\"skip_final_snapshot\":.*/\"skip_final_snapshot\": true,/g' "$SCRIPTPATH/terraform.tfstate" ;;
esac