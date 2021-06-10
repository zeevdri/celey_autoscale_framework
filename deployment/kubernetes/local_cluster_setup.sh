#!/bin/bash
# this script is not run ready, only documentation for commands to run
exit 0

minikube start --addons=registry --nodes=1

GPU_NODE="minikube"  # TODO change to appropriate note when minikube multi-nodes are enabled

# taint is not valid for the moment until minikube --nodes 2 will work with local docker image
#kubectl taint nodes $GPU_NODE gpu:NoSchedule

kubectl label nodes $GPU_NODE gpu=1

kubectl apply -f deployment/kubernetes/rabbitmq.yml -f deployment/kubernetes/redis.yml

eval "$(minikube docker-env)"
WORKER_VERSION=0.1
DOCKER_BUILDKIT=1 docker build . -t celery-worker:latest -t "celery-worker:$WORKER_VERSION"

