#!/bin/bash
# minikube setup
minikube stop
minikube delete
minikube start --kubernetes-version v1.19.3 --driver=virtualbox
kubectl apply -f vpa/components.yaml
# install vpa
vpa/autoscaler/vertical-pod-autoscaler/hack/vpa-up.sh
kubectl apply -f vpa/manifests .
# create deployment, service and vpa
# kubectl apply -f .
