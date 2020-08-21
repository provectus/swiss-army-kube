#Clear artifacts from previos version prometheus. Run clear-prom.sh <path to config> before run terraform apply
kubectl --kubeconfig=$1 -n kube-system delete ValidatingWebhookConfiguration prometheus-operator-admission
kubectl --kubeconfig=$1 -n kube-system delete MutatingWebhookConfiguration prometheus-operator-admission
kubectl --kubeconfig=$1 -n kube-system delete svc $(kubectl --kubeconfig=kubeconfig_lane-dev -n kube-system get svc | grep prometheus | awk {'print $1'})
kubectl --kubeconfig=$1 -n monitoring delete psp prometheus-operator-alertmanager prometheus-operator-grafana prometheus-operator-kube-state-metrics prometheus-operator-grafana-test prometheus-operator-operator prometheus-operator-prometheus prometheus-operator-prometheus-node-exporter
kubectl --kubeconfig=$1 -n monitoring delete crds $(kubectl --kubeconfig=kubeconfig_lane-dev -n monitoring get crds | grep monitoring | awk {'print $1'})
kubectl --kubeconfig=$1 -n monitoring delete clusterrole $(kubectl --kubeconfig=kubeconfig_lane-dev get clusterrole | grep prometheus | awk {'print $1'})
kubectl --kubeconfig=$1 -n monitoring delete clusterrolebinding $(kubectl --kubeconfig=kubeconfig_lane-dev get clusterrolebinding | grep prometheus | awk {'print $1'})
