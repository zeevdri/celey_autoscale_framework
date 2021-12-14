#!/bin/bash
# this script is not run ready, only documentation for commands to run
exit 0

# add keda dependency manually
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
kubectl create namespace keda
helm install keda kedacore/keda --namespace keda

CHART_PATH=./deployment/helm-local/celery-autoscale

helm dependency update $CHART_PATH

helm install celery-autoscale $CHART_PATH --debug --dry-run