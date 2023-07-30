import os
import uuid

import pytest
from workbench.coll import collection_api as coll

twitter_api_key = os.environ.get("BEARER_TOKEN")
bing_api_key = os.environ.get("BING_KEY")


@pytest.fixture
def tmp_collection():
    name = f"testing_{uuid.uuid4()}"
    coll.create_index(name, "testing")
    yield name
    try:
        coll.delete_index(name)
    except:
        # deletion is tested in another test case
        pass


# Twitter API is unusable due to recent changes to their policies.
"""
def test_getting_user_tweets(tmp_collection):
    status = coll.import_from_twitter(
        identifiers=["NobelPrize"],
        data_type="user",
        time_frame="week",
        relations=[],
        es_index_name=tmp_collection,
        api_key=twitter_api_key,
    )
    assert status == "Graph built successfully."


def test_user_tweets_timeframe(tmp_collection):
    status = coll.import_from_twitter(
        identifiers=["ualberta"],
        data_type="user",
        time_frame="week",
        relations=[],
        es_index_name=tmp_collection,
        api_key=twitter_api_key,
    )
    assert status == "Graph built successfully."


def test_user_tweets_with_relations(tmp_collection):
    status = coll.import_from_twitter(
        identifiers=["ualberta"],
        data_type="user",
        time_frame="week",
        relations=["like"],
        es_index_name=tmp_collection,
        api_key=twitter_api_key,
    )
    assert status == "Graph built successfully."

    status = coll.import_from_twitter(
        identifiers=["ualberta"],
        data_type="user",
        time_frame="week",
        relations=["embed"],
        es_index_name=tmp_collection,
        api_key=twitter_api_key,
    )
    assert status == "Graph built successfully."

    status = coll.import_from_twitter(
        identifiers=["ualberta"],
        data_type="user",
        time_frame="week",
        relations=["follow"],
        es_index_name=tmp_collection,
        api_key=twitter_api_key,
    )
    assert status == "Graph built successfully."

    status = coll.import_from_twitter(
        identifiers=["ualberta"],
        data_type="user",
        time_frame="week",
        relations=["retweet"],
        es_index_name=tmp_collection,
        api_key=twitter_api_key,
    )
    assert status == "Graph built successfully."

    status = coll.import_from_twitter(
        identifiers=["ualberta"],
        data_type="user",
        time_frame="week",
        relations=["mention"],
        es_index_name=tmp_collection,
        api_key=twitter_api_key,
    )
    assert status == "Graph built successfully."


def test_user_tweets_data_types(tmp_collection):
    status = coll.import_from_twitter(
        identifiers=["ualberta"],
        data_type="user",
        time_frame="week",
        relations=[],
        es_index_name=tmp_collection,
        api_key=twitter_api_key,
    )
    assert status == "Graph built successfully."

    status = coll.import_from_twitter(
        identifiers=["ualberta"],
        data_type="hashtag",
        time_frame="week",
        relations=[],
        es_index_name=tmp_collection,
        api_key=twitter_api_key,
    )
    assert status == "Graph built successfully."
"""

def test_local_file_import(tmp_collection):
    file_content = {
        "name": "example1",
        "description": "This is another example JSON file",
        "doc": [
            {
                "title": "Document 1",
                "author": "John Smith",
                "date": "2022-01-01",
                "text": "This is the first document",
                "content": "This is the first document",
            },
            {
                "title": "Document 2",
                "author": "Jane Doe",
                "date": "2022-01-02",
                "text": "This is the second document",
                "content": "This is the second document",
            },
        ],
    }

    status = coll.import_from_json(tmp_collection, file_content, "Testing")
    file_content = {
        "name": "example3",
        "description": "Yet another example JSON file",
        "doc": [
            {
                "name": "Person 1",
                "likes": 1123,
                "text": "This is the first Person tweet",
                "description": "This is the first Person",
            },
            {
                "name": "Person 2",
                "likes": 1123,
                "text": "This is the second Person tweet",
                "description": "This is the second Person",
            },
            {
                "name": "Person 3",
                "likes": 123,
                "text": "This is the third Person tweet",
                "description": "This is the second Person",
            },
        ],
    }
    status = coll.import_from_json(tmp_collection, file_content, "Testing")


def test_create_delete_collection(tmp_collection):
    status = coll.delete_index(tmp_collection)
    assert status is None


def test_pull_from_websearch():
    webpages = coll._pull_documents_from_search(
        "Edmonton Oilders", "news", bing_api_key, "en-CA", max_docs=5
    )
    assert len(webpages) > 0
