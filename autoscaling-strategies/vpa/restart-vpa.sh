#!/bin/bash

function waitDeployment(){
    echo "waiting for $1"
    while [[ $(kubectl get -n $2 pods -l $3=$1 -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}' | tr ' ' '\n' | sort | uniq) != "True" ]]; do echo && sleep 1; done
}


minikube delete
minikube start --kubernetes-version v1.19.3 --driver=virtualbox --cpus 4

kubectl apply -f components.yaml

waitDeployment 'metrics-server' 'kube-system' 'k8s-app'

./autoscaler/vertical-pod-autoscaler/hack/vpa-up.sh

(kubectl apply -f manifests/)

#kubectl wait -f manifests/busywait-vpa-deployment.yaml --for condition=available
waitDeployment 'busy-wait-vpa' 'default' 'app'
