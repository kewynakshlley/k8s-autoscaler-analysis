#!/bin/bash

(kubectl delete -f manifests/)

./autoscaler/vertical-pod-autoscaler/hack/vpa-down.sh
./autoscaler/vertical-pod-autoscaler/hack/vpa-up.sh

(kubectl apply -f manifests/)
minikube service busy-wait-vpa
