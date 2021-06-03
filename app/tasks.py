import logging

from celery import Celery, shared_task, Task

__all__ = ("app", "gpu_task", "cpu_task",)

__logger = logging.getLogger(__name__)

app = Celery("tasks")
app.config_from_object('celeryconfig')


@shared_task(name="gpu_task", queue="gpu", bind=True)
def gpu_task(self: Task, n: int):
    import time
    __logger.info(f"start processing '{self.name}'")
    time.sleep(n)
    __logger.info(f"finished processing '{self.name}'")
    return n + 1


@shared_task(name="cpu_task", queue="default", bind=True)
def cpu_task(self: Task, n: int):
    import time
    __logger.info(f"start processing '{self.name}'")
    time.sleep(n)
    __logger.info(f"finished processing '{self.name}'")
    return n + 1
