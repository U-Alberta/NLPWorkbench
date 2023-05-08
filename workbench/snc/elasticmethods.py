from elasticsearch import Elasticsearch
# import datetime
from datetime import datetime
from uuid import uuid4

def create_index(client: Elasticsearch, index_name, description):
    '''
    Attempts to create an index at the connection provided by client (ElasticSearch client).
    '''    
    if client is None:
        raise ValueError("Client is None")

    if client.indices.exists(index=index_name):
        raise ValueError("Index already exists")

    if type(description) != str:
        raise ValueError("Description must be string/text")

    mapping = {
        "mappings": {
            "dynamic": True,
            "_meta": {
                "description": description,
            },
            "properties": {
                "id": {"type": "keyword"}
            }
        }
    }   
    try:
        client.indices.create(
            index=index_name,
            body=mapping
        )

        log_index_name = index_name + "_log"
        log_mapping = {
            "mappings": {
                "_meta": {
                    "class": "log",
                    "description": "Log for index {}".format(index_name),
                }
            }
        }
        client.indices.create(index=log_index_name, body=log_mapping)
        
        log_doc_data = {
            "operation": "create",
            "description": description,
            "time": datetime.timestamp(datetime.now()),
        }
        client.create(index=log_index_name, id = str(uuid4()), body=log_doc_data)
        
    except Exception as e:
        raise ValueError("Error creating index: {}".format(e))

def delete_index(client: Elasticsearch, index_name):
    '''
    Attempts to delete an index at the connection provided by client (ElasticSearch client).
    '''
    if client is None:
        raise ValueError("Client is None")
    
    if not client.indices.exists(index=index_name):
        raise ValueError("Index doesn't exists")

    try:
        client.indices.delete(index=index_name)
        log_index_name = index_name + "_log"
        if client.indices.exists(index=log_index_name):
            client.indices.delete(index=log_index_name)
    except Exception as e:
        raise ValueError("Error deleting index: {}".format(e))
    
def read_log(client: Elasticsearch, index_name):

    log_index_name = index_name + "_log"
    if not client.indices.exists(index=log_index_name):
        raise ValueError("Log index does not exist for index {}".format(index_name))

    res = client.search(index=log_index_name, body={"query": {"match_all": {}}})

    log_docs = []
    for hit in res['hits']['hits']:
        log_docs.append(hit['_source'])

    return log_docs

def update_log_data(client: Elasticsearch, index_name, operation, imported_docs=None, source="Twitter", **params):

    if client is None or not client.indices.exists(index=index_name):
        raise ValueError("Client is None or index doesn't exists")

    log_index_name = index_name + "_log"

    log_doc_data = {
        "operation": operation,
        "time": datetime.timestamp(datetime.now()),
    }
    if source is not None:
        log_doc_data["source"] = source
    if imported_docs is not None:
        log_doc_data["imported_docs"] = imported_docs
    log_doc_data.update(params)

    # TODO: Need to handle the case if the index exists but log_index doesn't exist
    if client is not None and client.indices.exists(index=log_index_name):
        client.create(index=log_index_name, id = str(uuid4()), body=log_doc_data)
    else:
        raise ValueError("Client is None or Log Index doesn't exists")


def merge_doc(client: Elasticsearch, index_name, doc_id, doc_data, source="Twitter"):
    '''
    TODO: raise exceptions instead of returning integers
    Attempts to create/update a document within the provided index.
    Returns:    1 if successful
                0 if not (e.g. index does not exist)
    '''
    if client is None or not client.indices.exists(index=index_name):
        return 0

    # If document exists then update
    if client.exists(index=index_name, id=doc_id):
        try:
            client.update(index=index_name, id=doc_id, doc=doc_data)
        except Exception as e:
            print('[-] Error: ', e)
            return 0
    else:
        # Otherwise create a new document
        try:
            client.create(index=index_name, id=doc_id, document=doc_data)
        except Exception as e:
            print('[-] Error: ', e)
            return 0
        
    return 1