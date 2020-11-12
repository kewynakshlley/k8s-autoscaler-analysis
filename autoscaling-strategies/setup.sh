#!/bin/bash
# minikube setup
minikube stop
minikube delete
minikube start --kubernetes-version v1.19.3 --driver=virtualbox
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.0/components.yaml
# install vpa
vpa/autoscaler/vertical-pod-autoscaler/hack/vpa-up.sh

# create deployment, service and vpa
# kubectl apply -f .
