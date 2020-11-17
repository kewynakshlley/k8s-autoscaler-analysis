#!/bin/bash

minikube delete
minikube start --kubernetes-version v1.19.3 --driver=virtualbox --cpus 4
kubectl apply -f components.yaml
(kubectl apply -f manifests/)
