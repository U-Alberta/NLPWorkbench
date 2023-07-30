import sqlite3
from dataclasses import is_dataclass
import functools
import logging
import importlib.util
import sys
import re
from pathlib import Path
import time
from contextlib import contextmanager

try:
    import requests
except ImportError:
    # requests is only needed if using es_request
    pass

try:
    from flask import g
except ImportError:
    # flask is only present in the api server
    pass

from .config import Config


class RequestError(Exception):
    def __init__(self, message="Request error"):
        super.__init__(self)
        self.message = message


class ESCacheError(Exception):
    pass


def run_with_retries(f, max_retries=5, wait_secs=10):
    retries = 0
    while retries < max_retries:
        try:
            return f()
        except Exception:
            retries += 1
            logging.info(f"[+] Retrying connection... sleeping {retries * wait_secs}s")
            time.sleep(wait_secs * retries)
    return f()


def _create_es_connection():
    from elasticsearch import Elasticsearch

    es_client = Elasticsearch("http://elasticsearch:9200", basic_auth=Config.es_auth)
    assert es_client.ping()
    return es_client


def _create_neo4j_connection():
    from .coll.neoconnection import NeoConnection

    neo_connection = NeoConnection(
        uri="bolt://coll-neo4j:7687", user="neo4j", pwd="coll123"
    )
    neo_connection.session.run("RETURN 1")
    return neo_connection


@contextmanager
def connect_es():
    es_client = run_with_retries(_create_es_connection)
    try:
        yield es_client
    finally:
        es_client.close()


@contextmanager
def connect_neo4j():
    neo_connection = run_with_retries(_create_neo4j_connection)
    try:
        yield neo_connection
    finally:
        neo_connection.close()


def fix_es_news(news):
    # ingestion API uses `text` as the main field
    if "content" not in news:
        news["content"] = news["text"]

    if "url" in news:
        # url is sometimes concatenated with content
        # if so, we need to split it
        parts = re.split(r"\s+", news["url"], maxsplit=1)
        if len(parts) > 1:
            news["url"] = parts[0]
            news["content"] = parts[1]
    return news


def es_request(method, path, **kwargs):
    url = Config.es_url + path
    return requests.request(method, url, auth=Config.es_auth, verify=False, **kwargs)


def es_cache(key):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            bypass_cache = g.bypass_cache
            arg_cache_key = "||".join(f"{k}:{v}" for k, v in kwargs.items())
            if len(kwargs) > 0:
                arg_cache_key = "||" + arg_cache_key
            if len(args) > 0:
                for i, arg in enumerate(args):
                    arg_cache_key += f"||arg{i}:{arg}"
            logging.info("finding cache %s", key)
            if key in g.doc and not bypass_cache:
                if not arg_cache_key:
                    logging.info("cache hit, key: %s", key)
                    return g.doc[key]
                elif arg_cache_key in g.doc[key]:
                    logging.info(
                        "cache hit, key: %s; arg_cache_key: %s", key, arg_cache_key
                    )
                    return g.doc[key][arg_cache_key]

            logging.info("cache not hit, computing")
            result = func(*args, **kwargs)
            result = dictify(result)
            doc_id = g.doc["id"]
            try:
                es_writeback(g.collection, doc_id, key, result, arg_cache_key)
            except ESCacheError:
                logging.error(
                    f"Failed to cache {doc_id} with key: {key} and arg_cache_key: {arg_cache_key}"
                )

            if not arg_cache_key:
                g.doc[key] = result
            else:
                if key not in g.doc:
                    g.doc[key] = {}
                g.doc[key][arg_cache_key] = result
            return result

        return wrapper

    return decorator


def es_writeback(coll, doc_id, key, value, subkey=None):
    if key is None:
        es_query = {"doc": value}
    elif subkey:
        es_query = {"doc": {key: {subkey: value}}}
    else:
        es_query = {"doc": {key: value}}
    # FIXME: doesn't seem safe
    r = es_request(
        "POST",
        f"/{coll}/_update/{doc_id}?refresh=true",
        json=es_query,
    ).json()
    if r.get("result") not in ("updated", "noop"):
        logging.error(str(r))
        raise ESCacheError(str(r))
    return r


def dictify(obj):
    """
    Convert a list(-of) / dict(-of) dataclasses or primitive types to a dictionary.
    """
    if isinstance(obj, dict):
        return {k: dictify(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [dictify(v) for v in obj]
    elif is_dataclass(obj):
        if hasattr(obj, "asdict"):
            return obj.asdict()  # assume custom asdict is implemented
        else:
            return asdict(obj)
    else:
        return obj


def asdict(obj):
    """
    Convert a dataclass to a dictionary.
    """
    results = []
    for k, v in obj.__dict__.items():
        if is_dataclass(v):
            results.append((k, asdict(v)))
        else:
            results.append((k, v))
    return dict(results)


# https://docs.python.org/3/library/importlib.html#importing-a-source-file-directly
def dynamic_import(file_path, attr=None, register=False):
    file_path = Path(file_path)
    module_name = file_path.stem
    sys.path.append(str(file_path.parent))

    spec = importlib.util.spec_from_file_location(module_name, str(file_path))
    module = importlib.util.module_from_spec(spec)
    if register:
        sys.modules[module_name] = module
    spec.loader.exec_module(module)
    if attr is None:
        return module
    else:
        return getattr(module, attr)


class Models:
    """
    Lazy loading models
    """

    _nlp = None
    _sentence_transformer = None
    _vader = None
    _embedding_db = None
    _loaded_models = {}

    # @property & @classmethod do not work together
    # https://stackoverflow.com/questions/128573/using-property-on-classmethods/64738850#64738850
    @classmethod
    def vader(cls):
        if cls._vader is None:
            from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer

            cls._vader = SentimentIntensityAnalyzer()
        return cls._vader

    @classmethod
    def nlp(cls, *args, **kwargs):
        if cls._nlp is None:
            print("Loading SpaCy...")
            import spacy

            cls._nlp = spacy.load("en_core_web_sm")
            print("done")
        return cls._nlp(*args, **kwargs)

    @classmethod
    def encode_sentence(cls, *args, **kwargs):
        if cls._sentence_transformer is None:
            """
            Note: deep learning staff are imported here
            to avoid dependency conflicts
            """
            from sentence_transformers import SentenceTransformer

            print("Loading sentence encoder...")
            cache_path = (
                Path.home()
                / ".cache"
                / "torch"
                / "sentence_transformers"
                / "sentence-transformers_multi-qa-mpnet-base-dot-v1"
            )
            print("Checking cache path: ", str(cache_path))
            if cache_path.exists():
                print("Cache exists")
                cls._sentence_transformer = SentenceTransformer(str(cache_path))
            else:
                cls._sentence_transformer = SentenceTransformer(
                    "multi-qa-mpnet-base-dot-v1"
                )
            # TODO: move to gpu is available
            # cls._sentence_transformer.cuda()
            print("Done!")
        return cls._sentence_transformer.encode(*args, **kwargs)

    @classmethod
    def get_embedding_db_conn(cls):
        if cls._embedding_db is None:
            cls._embedding_db = sqlite3.connect(Config.embeddings_db)
            cls._embedding_db.execute(
                """
                CREATE TABLE IF NOT EXISTS entity_embeddings (
                    entity text primary key,
                    embedding blob
                )"""
            )
        return cls._embedding_db

    @classmethod
    def get_preloaded_model(cls, name):
        return cls._loaded_models.get(name)

    @classmethod
    def save_preloaded_model(cls, name, model):
        cls._loaded_models[name] = model
