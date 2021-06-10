imageName="celery-worker"
pip_freeze: requirements/requirements.txt
	pip freeze > requirements/requirements.lock.txt
docker_build: pip_freeze Dockerfile requirements/requirements.lock.txt .dockerignore app
	DOCKER_BUILDKIT=1 docker build . -t $(imageName):latest -t $(imageName):$(version)
