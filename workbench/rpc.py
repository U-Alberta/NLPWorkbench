"""
Remote (python) procedure call
"""
import logging
from functools import lru_cache

import dill

celery_available = False
try:
    from amqp.utils import str_to_bytes
    import kombu.serialization
    from celery import Celery

    celery_available = True
except ImportError:
    logging.info("Celery is not installed. Only XMLRPC is available.")

from .config import Config

logging.basicConfig(level=logging.INFO)


def dill_encoder(obj):
    return dill.dumps(obj, recurse=True)


def dill_decoder(encoded):
    return dill.loads(str_to_bytes(encoded))


@lru_cache(maxsize=None)
def create_celery(name, reroute=None):
    if celery_available:
        from celery.app import trace

        trace.LOG_SUCCESS = """Task %(name)s[%(id)s] succeeded in %(runtime)ss"""

        kombu.serialization.register(
            "dill",
            dill_encoder,
            dill_decoder,
            content_type="application/x-python-serialize",
            content_encoding="binary",
        )
        app = Celery(name, broker=Config.RPC.broker, backend=Config.RPC.backend)
        app.conf.task_serializer = "dill"
        app.conf.result_serializer = "dill"
        app.conf.accept_content = ["dill", "json"]
        app.conf.broker_transport_options = {"queue_order_strategy": "priority"}
        app.conf.task_routes = {"*": {"queue": name if reroute is None else reroute}}
        return app
    else:
        return DummyCelery()


class DummyCelery:
    def task(self, func):
        return func


if __name__ == "__main__":
    # test rpc server
    from dataclasses import is_dataclass

    def dictify(obj):
        if isinstance(obj, dict):
            return {k: dictify(v) for k, v in obj.items()}
        elif isinstance(obj, list):
            return [dictify(v) for v in obj]
        elif is_dataclass(obj):
            return obj.asdict()  # assume custom asdict is implemented
        else:
            return obj

    clients = get_rpc_clients()
    output = clients.ner.run_ner("Hello", "Google is a company")
    print(dictify(output))
