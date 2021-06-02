# syntax = docker/dockerfile:1.2
ARG PYTHON_VERSION=3.8.10
FROM python:${PYTHON_VERSION}-slim-buster
ENV PYTHONUNBUFFERED=1
ENV WORKER_QUEUE=default
ENV WORKER_NAME=default
ENV CELERY_BROKER_URL=amqp://localhost:5672
ENV CELERY_RESULTS_BACKEND=redis://localhost:6379
WORKDIR /app
COPY requirements.lock.txt /app/requirements.txt
RUN --mount=type=cache,target=/root/.cache \
    pip install -r requirements.txt
COPY . /app/
CMD celery -A tasks worker --loglevel INFO --queues ${WORKER_QUEUE} -n ${WORKER_NAME}
