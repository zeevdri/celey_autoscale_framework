## Architecture
### Infrastructure
* python Docker
* Celery based system
* SAS Queue to init requests
* Kubernetes
  - Autoscaling node clusters (0 <=)
  - Autoscaling pod cluster (0 <=)
### Devops tools
* Terraform for infrastructure deployment
* helm for kubernetes charts management
### Dev env
required software:
* rabbitmq
* redis server
* minikube
* python3.6
* docker