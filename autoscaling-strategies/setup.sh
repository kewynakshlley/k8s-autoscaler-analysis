#!/bin/bash
# minikube setup
minikube stop
minikube delete
minikube start --kubernetes-version v1.19.3 --driver=virtualbox --cpus 4 
kubectl apply -f vpa/components.yaml
# install vpa

# create deployment, service and vpa
# kubectl apply -f .
