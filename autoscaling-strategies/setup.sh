#!/bin/bash
# minikube setup
minikube delete
minikube start
minikube addons enable metrics-server

# install vpa
#./autoscaler/vertical-pod-autoscaler/hack/vpa-up.sh

# create deployment, service and vpa
# kubectl apply -f .
