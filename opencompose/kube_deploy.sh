#!/bin/sh

if [[ $1 == "create" ]]; then
	kubectl create -f cgtd-service.yaml -f cgtd-deployment.yaml -f ipfs-cluster-service.yaml -f ipfs-cluster-deployment.yaml
elif [[ $1 == "delete" ]]; then
	kubectl delete services --all
	kubectl delete deployments --all
	kubectl delete pods --all
fi
