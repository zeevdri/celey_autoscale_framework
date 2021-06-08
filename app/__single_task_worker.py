from celery.worker import WorkController
from celery.worker.components import Consumer
from celery.worker.consumer.tasks import Tasks


class SingleTaskWorkController(WorkController):

    def setup_defaults(self, concurrency=None, loglevel='WARN', logfile=None, task_events=None, pool=None,
                       consumer_cls=None, timer_cls=None, timer_precision=None, autoscaler_cls=None, pool_putlocks=None,
                       pool_restarts=None, optimization=None, O=None, statedb=None, time_limit=None,
                       soft_time_limit=None, scheduler=None, pool_cls=None, state_db=None, task_time_limit=None,
                       task_soft_time_limit=None, scheduler_cls=None, schedule_filename=None, max_tasks_per_child=None,
                       prefetch_multiplier=None, disable_rate_limits=None, worker_lost_wait=None,
                       max_memory_per_child=None, **_kw):
        super().setup_defaults(1, loglevel, logfile, task_events, pool, consumer_cls, timer_cls,
                               timer_precision, autoscaler_cls, pool_putlocks, pool_restarts, optimization, O, statedb,
                               time_limit, soft_time_limit, scheduler, pool_cls, state_db, task_time_limit,
                               task_soft_time_limit, scheduler_cls, schedule_filename, max_tasks_per_child,
                               prefetch_multiplier, disable_rate_limits, worker_lost_wait, max_memory_per_child, **_kw)


# TODO implement a callback after task success to call SingleTaskWorkController.stop(),
#  this should be before another task is consumed
