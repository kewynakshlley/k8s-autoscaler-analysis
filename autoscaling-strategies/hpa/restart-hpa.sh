#!/bin/bash

function waitMetrics(){
    while [[ $(kubectl get -n $2 pods -l $3=$1 -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}' | tr ' ' '\n' | sort | uniq) != "True" ]]; do echo "waiting for $1" && sleep 5; done
}

function waitDeployment(){
    while [[ $(kubectl get pods -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}' | tr ' ' '\n' | sort | uniq) != "True" ]]; do echo "waiting for $1" && sleep 5; done
}


minikube delete
minikube start --kubernetes-version v1.19.3 --driver=virtualbox --cpus 4

kubectl apply -f components.yaml

waitMetrics 'metrics-server' 'kube-system' 'k8s-app'

kubectl apply -f manifests/

kubectl wait -f manifests/busywait-hpa-deployment.yaml --for condition=available

