import os

import kombu

broker_url = os.environ["CELERY_BROKER_URL"]
result_backend = os.environ["CELERY_RESULTS_BACKEND"]

task_acks_late = True

task_queues = (
    kombu.Queue("default", kombu.Exchange("default"), routing_key="default"),
    kombu.Queue("gpu", kombu.Exchange("gpu"), routing_key="gpu"),
)

enable_utc = True
timezone = os.environ.get("CELERY_TIMEZONE", "Asia/Jerusalem")
