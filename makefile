pip_freeze: requirements/requirements.txt
	pip freeze > requirements/requirements.lock.txt
docker_build: pip_freeze Dockerfile requirements/requirements.lock.txt .dockerignore app app
	docker build . -t celery_worker
