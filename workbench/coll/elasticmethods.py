import logging
from datetime import datetime
from uuid import uuid4

from elasticsearch import Elasticsearch

from ..config import Config
from ..utils import RequestError

LOG_INDEX_NAME = Config.es_log_index_name


def create_index(client: Elasticsearch, index_name, description):
    """
    Attempts to create an index at the connection provided by client (ElasticSearch client).
    """
    assert client is not None
    assert type(description) == str

    if client.indices.exists(index=index_name):
        raise RequestError("Index already exists")

    mapping = {
        "mappings": {
            "dynamic": True,
            "_meta": {
                "description": description,
            },
            "properties": {
                "id": {"type": "keyword"},
            },
        }
    }
    client.indices.create(index=index_name, body=mapping)

    if not client.indices.exists(index=LOG_INDEX_NAME):
        log_mapping = {
            "mappings": {
                "_meta": {
                    "class": "log",
                    "description": "Reserved index storing all system logs.",
                },
                "properties": {"collection": {"type": "keyword"}},
            }
        }
        client.indices.create(index=LOG_INDEX_NAME, body=log_mapping)

    log_doc_data = {
        "collection": index_name,
        "operation": "create",
        "description": description,
        "time": datetime.timestamp(datetime.now()),
    }
    client.create(index=LOG_INDEX_NAME, id=str(uuid4()), body=log_doc_data)


def delete_index(client: Elasticsearch, index_name):
    """
    Attempts to delete an index at the connection provided by client (ElasticSearch client).
    """
    assert client is not None
    if not client.indices.exists(index=index_name):
        raise RequestError("Index doesn't exists")
    client.indices.delete(index=index_name)


def read_log(client: Elasticsearch, index_name):
    res = client.search(
        index=LOG_INDEX_NAME, body={"query": {"term": {"collection": index_name}}}
    )
    log_docs = [x["_source"] for x in res["hits"]["hits"]]
    logging.info(log_docs)

    # if a collection is deleted, and a new collection with the same name
    # is created afterwards, we should only keep the log items after the creation event
    log_docs = sorted(log_docs, key=lambda x: x["time"], reverse=True)
    log_docs_it = iter(log_docs)
    filtered_log_docs = []
    for doc in log_docs_it:
        del doc["collection"]
        filtered_log_docs.append(doc)
        if doc["operation"] == "create":
            break
    return filtered_log_docs


def update_log_data(
    client: Elasticsearch,
    index_name,
    operation,
    imported_docs=None,
    source="Twitter",
    **params
):
    assert client is not None
    assert client.indices.exists(index=index_name)
    log_doc_data = {
        "collection": index_name,
        "operation": operation,
        "time": datetime.timestamp(datetime.now()),
    }
    if source is not None:
        log_doc_data["source"] = source
    if imported_docs is not None:
        log_doc_data["imported_docs"] = imported_docs
    log_doc_data.update(params)
    client.create(index=LOG_INDEX_NAME, id=str(uuid4()), body=log_doc_data)


def merge_doc(client: Elasticsearch, index_name, doc_id, doc_data, source="Twitter"):
    """
    TODO: raise exceptions instead of returning integers
    Attempts to create/update a document within the provided index.
    Returns:    1 if successful
                0 if not (e.g. index does not exist)
    """
    if client is None or not client.indices.exists(index=index_name):
        return 0

    # If document exists then update
    if client.exists(index=index_name, id=doc_id):
        try:
            client.update(index=index_name, id=doc_id, doc=doc_data)
        except Exception as e:
            print("[-] Error: ", e)
            return 0
    else:
        # Otherwise create a new document
        try:
            client.create(index=index_name, id=doc_id, document=doc_data)
        except Exception as e:
            print("[-] Error: ", e)
            return 0

    return 1
