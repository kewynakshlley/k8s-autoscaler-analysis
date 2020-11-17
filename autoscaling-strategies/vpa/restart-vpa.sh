#!/bin/bash

(kubectl delete -f manifests/busywait-vpa-deployment.yaml)
(kubectl delete -f manifests/my-vpa.yaml)

./autoscaler/vertical-pod-autoscaler/hack/vpa-down.sh
./autoscaler/vertical-pod-autoscaler/hack/vpa-up.sh

(kubectl apply -f manifests/)
