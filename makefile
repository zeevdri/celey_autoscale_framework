pip_freeze:
	pip freeze > requirements.lock.txt
docker_build: pip_freeze
	docker build . -t celery_worker
