from elasticsearch import Elasticsearch

def create_index(client: Elasticsearch, index_name):
    '''
    Attempts to create an index at the connection provided by client (ElasticSearch client).
    Returns:    1 if successful
                0 if not (e.g. index already exists)
    '''    
    if client is None or client.indices.exists(index=index_name):
        return 0

    mapping = {
        "mappings": {
            "_meta": {
                "class": "social_network"
            }
        }
    }   
    try:
        client.indices.create(
            index=index_name,
            body=mapping
        )
    except Exception as e:
        print('[-] Error: ', e)

    return 1

def delete_index(client: Elasticsearch, index_name):
    '''
    Attempts to delete an index at the connection provided by client (ElasticSearch client).
    Returns:    1 if successful
                0 if not (e.g. index does not exist)
    '''
    if client is None or not client.indices.exists(index=index_name):
        return 0

    try:
        client.indices.delete(index=index_name)
    except Exception as e:
        print('[-] Error: ', e)

    return 1

def merge_doc(client: Elasticsearch, index_name, doc_id, doc_data):
    '''
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