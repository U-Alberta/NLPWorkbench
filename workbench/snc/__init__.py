import time
from datetime import datetime
from dateutil.relativedelta import relativedelta
import logging
from contextlib import contextmanager

from ..rpc import create_celery
from . import config

try:
    import tweepy
    from elasticsearch import Elasticsearch

    from .neoconnection import NeoConnection
    from .collection_constructors import build_tweet_collection, build_username_collection, build_hashtag_collection
    from .elasticmethods import create_index
except ImportError:
    logging.warning(
        "dependencies are not installed. This is expected if calling celery tasks."
    )

celery = create_celery("workbench.snc", "snc")

def run_with_retries(f, max_retries=5, wait_secs=10):
    retries = 0
    while retries < max_retries:
        try:
            return f()
        except Exception as e:
            retries += 1
            logging.info(f"[+] Retrying connection... sleeping {retries * wait_secs}s")
            time.sleep(wait_secs * retries)
    return f()

def connect_es():
    es_client       = Elasticsearch(
        "http://elasticsearch:9200",
        basic_auth=("elastic", config.ELASTIC_PASSWORD)
    )
    assert es_client.ping()
    return es_client

def connect_neo4j():
    neo_connection = NeoConnection(uri="bolt://snc-neo4j:7687", user="neo4j", pwd="snc123")
    neo_connection.session.run("RETURN 1")
    return neo_connection

@celery.task
def run_snc(identifiers, data_type, time_frame, relations, es_index_name):
    '''
    Creates (or updates) a collection (index within ES, network within neo4j) with the provided data.
    Args:   identifiers - a set of either twitter usernames, tweet IDs, or hashtags
            data_type - specifies the type of data passed (one of the three mentioned above -> either 'username', 'tweet', or 'hashtag')
            time_frame - the time frame from which data is to be pulled (i.e. if 'week' then all data within the last 7 days is pulled)
            relations - the set of relations which are to be pulled from twitter's API 
                        (e.g. ['like', 'embed'] to pull all likers of tweets and embedded entities within tweets, respectively)
                        (all possible relations: ['like', 'embed', 'follow', 'retweet', 'mention'])
            es_index_name - the name of the index (within elastic search) to create (or update if already existent)
    '''

    '''Certain parts of this function are commented out as they were previously implemented to be ran from a CLI.
    Now, the data, type of data (username/tweet handles), and time frame (e.g. week, month, etc.) should be passed to an API endpoint
    within the workbench (via a POST request) which will then call this method and provide this data.'''
    neo_connection, tweepy_client, es_client = None, None, None
    tweepy_client   = tweepy.Client(bearer_token=config.BEARER_TOKEN)
    neo_connection = run_with_retries(connect_neo4j)
    es_client = run_with_retries(connect_es)

    start_date = None
    if time_frame == "week":        # week
        start_date = datetime.today() - relativedelta(weeks=1)
    elif time_frame == "month":     # month
        start_date = datetime.today() - relativedelta(months=1)
    elif time_frame == "3month":    # 3 months
        start_date = datetime.today() - relativedelta(months=3)
    else:  # other
        return "[-] Error: other time frame not implemented yet..."

    create_index(es_client, index_name=es_index_name)       # create_index handles all cases (index exists or index does not exist)
    
    if data_type == "user":        # Build network from usernames
        build_username_collection(neo_connection, tweepy_client, es_client, identifiers, start_date, relations, es_index_name)
    elif data_type == "tweet":     # Build network from tweet id's
        build_tweet_collection(neo_connection, tweepy_client, es_client, identifiers, start_date, relations, es_index_name)
    elif data_type == "hashtag":    # Build network based on tweets mentioning a hashtag
        build_hashtag_collection(neo_connection, tweepy_client, es_client, identifiers, start_date, relations, es_index_name)
    else:
        raise ValueError("Unsuported data type: {}".format(data_type))

    """Page centrality algorithms -- can be implemented later (add option to run centrality algorithms in front-end, pass necessary data and call run_pagerank)"""
    #     run_pagerank(neo_connection, name='annotatedOrganizations', entities=['Organization','Tweet'], rel='ANNOTATES', attribute='description')
    #     run_pagerank(neo_connection, name='mentionedUsers', entities=['User','Tweet'], rel='MENTIONS', attribute='username')
    #     run_pagerank(neo_connection, name='annotatedPlaces', entities=['Place','Tweet'], rel='ANNOTATES', attribute='description')

    """Subgraph functionality -- can add option to build subgraph on a given user (simply call get_subgraph_query and return the built query to user (to be ran in neo4j browser)"""
    # username = input("Enter the username of an entity in the graph: ")
    # query = get_subgraph_query(neo_connection, username)
    # if query is not None:
        # pass          # return the query to the user

    neo_connection.close()
    es_client.close()
    return "Graph built successfully."
