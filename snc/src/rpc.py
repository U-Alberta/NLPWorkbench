"""
Remote (python) procedure call
"""
import logging
from xmlrpc.server import SimpleXMLRPCServer
from xmlrpc.server import SimpleXMLRPCRequestHandler
from xmlrpc.client import ServerProxy
import os

import dill

celery_available = False
try:
    from amqp.utils import str_to_bytes
    import kombu.serialization
    from celery import Celery

    celery_available = True
except ImportError:
    print("Celery is not installed. Only XMLRPC is available.")

logging.basicConfig(level=logging.INFO)

broker = os.environ.get("RPC_BROKER", "redis://:UTLhRXzpeF5sa2QjRch5PPl2EJx1H2@redis")
backend = os.environ.get("RPC_BACKEND", "redis://:UTLhRXzpeF5sa2QjRch5PPl2EJx1H2@redis")


def dill_encoder(obj):
    return dill.dumps(obj, recurse=True)


def dill_decoder(encoded):
    return dill.loads(str_to_bytes(encoded))


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
        app = Celery(name, broker=broker, backend=backend)
        app.conf.task_serializer = "dill"
        app.conf.result_serializer = "dill"
        app.conf.accept_content = ["dill", "json"]
        app.conf.broker_transport_options = {"queue_order_strategy": "priority"}
        app.conf.task_routes = {"*": {"queue": name if reroute is None else reroute}}
        return app
    else:
        return DummyCelery()


class RPCServer:
    def __init__(self):
        import warnings

        warnings.warn(
            "RPCServer is deprecated. Use celery instead.", DeprecationWarning
        )
        self._registered_rpc_functions = {}

    def register(self, func, name=None):
        if name is None:
            name = func.__name__
        print("registering RPC function '{}'".format(name))
        if name in self._registered_rpc_functions:
            raise ValueError(f"RPC function '{name}' already registered")
        self._registered_rpc_functions[name] = func
        return func

    def reply(self, func_name, *args, **kwargs):
        logging.info(f"Handling remote call {func_name}")
        if func_name not in self._registered_rpc_functions:
            raise ValueError(f"RPC function '{func_name}' not registered")
        func = self._registered_rpc_functions[func_name]
        args = [dill.loads(x) for x in args]
        kwargs = {k: dill.loads(v) for k, v in kwargs.items()}
        return dill.dumps(func(*args, **kwargs), recurse=True)

    def serve(self, host, port):
        with SimpleXMLRPCServer(
            (host, port),
            requestHandler=SimpleXMLRPCRequestHandler,
            use_builtin_types=True,
        ) as server:
            server.register_function(self.reply)
            print("Serving...", flush=True)
            server.serve_forever()


class RPCClient:
    def __init__(self, host, port):
        import warnings

        warnings.warn(
            "RPCClient is deprecated. Use celery instead.", DeprecationWarning
        )
        self.server = ServerProxy(f"http://{host}:{port}", use_builtin_types=True)

    def call(self, func_name, *args, **kwargs):
        logging.info(f"Calling remote function {func_name}")
        args = [dill.dumps(x, recurse=True) for x in args]
        kwargs = {k: dill.dumps(v, recurse=True) for k, v in kwargs.items()}
        resp = self.server.reply(func_name, *args, **kwargs)
        return dill.loads(resp)

    def __getattr__(self, func_name):
        def call(*args, **kwargs):
            return self.call(func_name, *args, **kwargs)

        return call


class LocalMockClient:
    def __init__(self, *args, **kwargs):
        pass

    def run_ner(self, *args, **kwargs):
        from ner import run_ner

        return run_ner(*args, **kwargs)

    def run_linker(self, *args, **kwargs):
        from linker import run_linker

        return run_linker(*args, **kwargs)

    def run_amr_parsing(self, *args, **kwargs):
        from semantic import run_amr_parsing

        return run_amr_parsing(*args, **kwargs)

    def run_amr_to_text(self, *args, **kwargs):
        from semantic import run_amr_to_text

        return run_amr_to_text(*args, **kwargs)


def get_rpc_clients():
    from config import Config

    class RemoteClients:
        ner = (
            RPCClient(Config.RPC.ner_host, Config.RPC.ner_port)
            if Config.RPC.ner_remote
            else LocalMockClient()
        )
        linker = (
            RPCClient(Config.RPC.linker_host, Config.RPC.linker_port)
            if Config.RPC.linker_remote
            else LocalMockClient()
        )
        amr = (
            RPCClient(Config.RPC.amr_host, Config.RPC.amr_port)
            if Config.RPC.amr_remote
            else LocalMockClient()
        )
        amr2text = (
            RPCClient(Config.RPC.amr2text_host, Config.RPC.amr2text_port)
            if Config.RPC.amr2text_remote
            else LocalMockClient()
        )

    return RemoteClients


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
