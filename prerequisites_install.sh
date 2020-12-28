#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

brew install helm kubernetes-cli awscli aws-iam-authenticator terraform jq
echo
echo "Installed helm version:"
helm version
echo
echo "Installed kubectl version:"
kubectl version --client
echo
echo "Installed awscli version:"
aws --version
echo
echo "Installed aws-iam-authenticator version:"
aws-iam-authenticator version
echo
echo "Installed terraform version:"
terraform version | head -n 1
echo
echo "Installed jq version:"
jq --version
echo