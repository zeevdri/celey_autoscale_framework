pip_freeze: requirements.txt
	pip freeze > requirements.lock.txt
docker_build: pip_freeze Dockerfile requirements.lock.txt .dockerignore celeryconfig.py tasks.py
	docker build . -t celery_worker
