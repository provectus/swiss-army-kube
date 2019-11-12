#!/bin/sh -x

helm install --name cert-manager --namespace cert-manager --version v0.11.0 --wait jetstack/cert-manager
helm install --name cert-issuer --namespace cert-manager --wait . $@
