#!/bin/bash
# this script is not run ready, only documentation for commands to run
exit 0

minikube start --addons=registry --nodes=1

GPU_NODE="minikube"  # TODO change to appropriate note when minikube multi-nodes are enabled

# taint is not valid for the moment until minikube --nodes 2 will work with local docker image
#kubectl taint nodes $GPU_NODE gpu:NoSchedule
kubectl create namespace celery-autoscale
kubectl label nodes $GPU_NODE gpu=1

eval "$(minikube docker-env)"
WORKER_VERSION=0.1
DOCKER_BUILDKIT=1 docker build . -t celery-worker:latest -t "celery-worker:$WORKER_VERSION"

kubectl apply -f deployment/kubernetes/celery-broker.yml -f deployment/kubernetes/celery-results.yml
kubectl apply -f deployment/kubernetes/default-worker.yml -f deployment/kubernetes/gpu-worker.yml
kubectl apply -f deployment/kubernetes/autoscaler-auth.yml
kubectl apply -f deployment/kubernetes/default-worker-autoscaler.yml -f deployment/kubernetes/gpu-worker-autoscaler.yml
