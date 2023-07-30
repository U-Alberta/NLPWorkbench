from datetime import datetime
import logging
import asyncio
from concurrent.futures import ThreadPoolExecutor
from uuid import uuid4

import requests

from ..utils import connect_es, connect_neo4j
from ..bing_search import search_topk_news, search_topk_webpages
from ..rpc import create_celery
from . import elasticmethods

try:
    from newspaper import Article
    from dateutil.relativedelta import relativedelta
    import tweepy
    from .twitter_collection_builder import (
        build_tweet_collection,
        build_username_collection,
        build_hashtag_collection,
    )
except ImportError as e:
    import os

    if os.environ.get("RPC_CALLER") is None:
        raise e

celery = create_celery("workbench.coll", "coll")


def create_index(es_index_name, description):
    with connect_es() as es_client:
        elasticmethods.create_index(
            es_client, index_name=es_index_name, description=description
        )
        logging.info("A: Create Index Successful")


def delete_index(es_index_name):
    with connect_es() as es_client:
        elasticmethods.delete_index(es_client, index_name=es_index_name)
        logging.info("A: Delete index successful")


def get_index_log(es_index_name):
    if es_index_name is None or len(es_index_name) < 2:
        return "Collection Index Name is Required"

    with connect_es() as es_client:
        log_list = elasticmethods.read_log(es_client, es_index_name)

        if log_list is None:
            return "Collection Index doesn't exist"

    return log_list


@celery.task
def import_from_twitter(
    identifiers, data_type, time_frame, relations, es_index_name, api_key
):
    '''
    Creates (or updates) a collection (index within ES, network within neo4j) with the provided data.
    Args:   identifiers - a set of either twitter usernames, tweet IDs, or hashtags
            data_type - specifies the type of data passed (one of the three mentioned above -> either 'username', 'tweet', or 'hashtag')
            time_frame - the time frame from which data is to be pulled (i.e. if 'week' then all data within the last 7 days is pulled)
            relations - the set of relations which are to be pulled from twitter's API
                        (e.g. ['like', 'embed'] to pull all likers of tweets and embedded entities within tweets, respectively)
                        (all possible relations: ['like', 'embed', 'follow', 'retweet', 'mention'])
            es_index_name - the name of the index (within elastic search) to create (or update if already existent)
    """

    """Certain parts of this function are commented out as they were previously implemented to be ran from a CLI.
    Now, the data, type of data (username/tweet handles), and time frame (e.g. week, month, etc.) should be passed to an API endpoint
    within the workbench (via a POST request) which will then call this method and provide this data.
    '''
    tweepy_client = tweepy.Client(bearer_token=api_key)
    with connect_es() as es_client, connect_neo4j() as neo_connection:
        # with connect_es() as es_client:
        # neo_connection = None
        start_date = None
        if time_frame == "week":  # week
            start_date = datetime.today() - relativedelta(weeks=1)
        elif time_frame == "month":  # month
            start_date = datetime.today() - relativedelta(months=1)
        elif time_frame == "3month":  # 3 months
            start_date = datetime.today() - relativedelta(months=3)
        else:  # other
            return "[-] Error: other time frame not implemented yet..."

        if data_type == "user":  # Build network from usernames
            imported_docs = build_username_collection(
                neo_connection,
                tweepy_client,
                es_client,
                identifiers,
                start_date,
                relations,
                es_index_name,
            )
        elif data_type == "tweet":  # Build network from tweet id's
            imported_docs = build_tweet_collection(
                neo_connection,
                tweepy_client,
                es_client,
                identifiers,
                start_date,
                relations,
                es_index_name,
            )
        elif (
            data_type == "hashtag"
        ):  # Build network based on tweets mentioning a hashtag
            imported_docs = build_hashtag_collection(
                neo_connection,
                tweepy_client,
                es_client,
                identifiers,
                start_date,
                relations,
                es_index_name,
            )
        else:
            raise ValueError("Unsuported data type: {}".format(data_type))
        elasticmethods.update_log_data(
            es_client,
            es_index_name,
            "update",
            imported_docs,
            "Twitter",
            data_type=data_type,
            relations=relations,
            identifiers=identifiers,
            time_frame=time_frame,
        )

        """Page centrality algorithms -- can be implemented later (add option to run centrality algorithms in front-end, pass necessary data and call run_pagerank)"""
        #     run_pagerank(neo_connection, name='annotatedOrganizations', entities=['Organization','Tweet'], rel='ANNOTATES', attribute='description')
        #     run_pagerank(neo_connection, name='mentionedUsers', entities=['User','Tweet'], rel='MENTIONS', attribute='username')
        #     run_pagerank(neo_connection, name='annotatedPlaces', entities=['Place','Tweet'], rel='ANNOTATES', attribute='description')

        """Subgraph functionality -- can add option to build subgraph on a given user (simply call get_subgraph_query and return the built query to user (to be ran in neo4j browser)"""
        # username = input("Enter the username of an entity in the graph: ")
        # query = get_subgraph_query(neo_connection, username)
        # if query is not None:
        # pass          # return the query to the user

    return "Graph built successfully."


@celery.task
def import_from_json(es_index_name, file_content, source="JSON file"):
    # TODO: find a way to handle errors in rpc, other than returning a string
    assert es_index_name is not None
    if "doc" not in file_content:
        raise KeyError("Doc Element is Required to Import JSON file")

    if len(file_content["doc"]) <= 0:
        raise ValueError("Doc element is required to have at least one object.")

    for doc in file_content["doc"]:
        if "text" not in doc:
            raise KeyError("Each document object must have a `text` field")

        if not isinstance(doc["text"], str):
            raise ValueError("`text` field must be a string")

    imported_doc_ids = []
    with connect_es() as es_client:
        for doc in file_content["doc"]:
            # Merge into elastic search (handles both update or creation)
            # FIXME: handle errors
            if "id" not in doc:
                doc["id"] = str(uuid4())
            elasticmethods.merge_doc(
                client=es_client,
                index_name=es_index_name,
                doc_id=doc["id"],
                doc_data=doc,
                source="LocalFile",
            )
            imported_doc_ids.append(doc["id"])
        elasticmethods.update_log_data(
            es_client, es_index_name, "update", len(file_content["doc"]), source
        )
    return imported_doc_ids


def _pull_webpage(url):
    try:
        r = requests.get(url, timeout=20)
        r.raise_for_status()
        return r.text
    except:
        return None


def _pull_documents_from_search(
    q,
    media_type,
    key,
    region,
    max_docs,
    freshness="Any",
    news_category="Any",
    start_date=None,
    end_date=None,
):
    assert media_type in ("news", "webpage")
    logging.info("searching bing...")
    if media_type == "news":
        search_results = search_topk_news(
            q, region, key, news_category, freshness, max_docs
        )
    else:
        search_results = search_topk_webpages(
            q, region, key, freshness, start_date, end_date, max_docs
        )
    logging.info(f"search results: {len(search_results['docs'])} docs")

    if len(search_results["docs"]) == 0:
        pages = []
    else:
        logging.info("start pulling webpages")

        async def _pull():
            loop = asyncio.get_running_loop()
            with ThreadPoolExecutor(max_workers=20) as pool:
                jobs = [
                    loop.run_in_executor(pool, _pull_webpage, x["url"])
                    for x in search_results["docs"]
                ]
                jobs = asyncio.gather(*jobs)
                return await jobs

        pages = asyncio.run(_pull())
    logging.info(f"pulled {len(pages)} webpages")

    # extract content from webpages
    new_docs = []
    for search_result, webpage in zip(search_results["docs"], pages):
        if webpage is None:
            continue
        try:
            article = Article("")
            article.download(webpage)
            article.parse()
        except:
            continue
        new_docs.append(
            {
                "title": article.title,
                "text": article.text,
                "url": search_result["url"],
                "author": "; ".join(article.authors),
                "published": article.publish_date,
            }
        )
    logging.info(f"extracted contents from {len(new_docs)} webpages")
    return new_docs


@celery.task
def import_from_search(
    collection,
    q,
    media_type,
    key,
    region,
    max_docs,
    freshness="Any",
    news_category="Any",
    start_date=None,
    end_date=None,
):
    docs = _pull_documents_from_search(
        q,
        media_type,
        key,
        region,
        max_docs,
        freshness,
        news_category,
        start_date,
        end_date,
    )
    # TODO: write parameters into log
    if len(docs) > 0:
        r = import_from_json(collection, {"doc": docs}, source="News Search")
    logging.info(f"imported {len(docs)} webpages")
    return len(docs)
