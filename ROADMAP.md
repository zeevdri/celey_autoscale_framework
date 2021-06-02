The finale system should be a cloud based autoscaling cluster to serve different workloads.

# Development steps
## Local POC
### 1. Local Running Environment - DONE
* celery
* process based running workers
* with tasks routing
### 2. Local Docker Environment - Done
workers run on dockers
* write Dockerfile 
### 3. Local Kubernetes Environment
1. initial env
  * workers run on pods
  * write deployment
2. pods autoscaling
  pods autoscaling according to tasks in queue.
  * scale to 0.
  * max pods allowed
  * number of allowed pending tasks in queue
3. convert deployment to helm
## Cloud POC
### 1. setup









