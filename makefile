pip_freeze: requirements.txt
	pip freeze > requirements.lock.txt
docker_build: pip_freeze Dockerfile requirements.lock.txt .dockerignore celery_autoscale_framework/celeryconfig.py celery_autoscale_framework/tasks.py
	docker build . -t celery_worker
