# syntax = docker/dockerfile:1.3
FROM python:3.8

COPY requirements.lock.txt requirements.txt
RUN --mount=type=cache,target=/root/.cache \
    pip install -r requirements.txt
