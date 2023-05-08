from workbench import snc

def test_getting_user_tweets():
    status = snc.run_snc(identifiers=["NobelPrize"], description="", data_type="user", time_frame="week", relations=[], es_index_name="test_index")
    assert status == "Graph built successfully."

def test_user_tweets_timeframe():
    # status = snc.run_snc(identifiers=["NobelPrize"], description="", data_type="user", time_frame="month", relations=[], es_index_name="test_index")
    # assert status == "Graph built successfully."

    # status = snc.run_snc(identifiers=["NobelPrize"], description="", data_type="user", time_frame="3month", relations=[], es_index_name="test_index")
    # assert status == "Graph built successfully."

    status = snc.run_snc(identifiers=["ualberta"], description="", data_type="user", time_frame="week", relations=[], es_index_name="ualberta")
    assert status == "Graph built successfully."

def test_user_tweets_with_relations():
    status = snc.run_snc(identifiers=["ualberta"], description="", data_type="user", time_frame="week", relations=["like"], es_index_name="ualberta")
    assert status == "Graph built successfully."

    status = snc.run_snc(identifiers=["ualberta"], description="", data_type="user", time_frame="week", relations=["embed"], es_index_name="ualberta")
    assert status == "Graph built successfully."

    status = snc.run_snc(identifiers=["ualberta"], description="", data_type="user", time_frame="week", relations=["follow"], es_index_name="ualberta")
    assert status == "Graph built successfully."

    status = snc.run_snc(identifiers=["ualberta"], description="", data_type="user", time_frame="week", relations=["retweet"], es_index_name="ualberta")
    assert status == "Graph built successfully."

    status = snc.run_snc(identifiers=["ualberta"], description="", data_type="user", time_frame="week", relations=["mention"], es_index_name="ualberta")
    assert status == "Graph built successfully."

def test_user_tweets_data_types():
    status = snc.run_snc(identifiers=["ualberta"], description="", data_type="user", time_frame="week", relations=[], es_index_name="ualberta")
    assert status == "Graph built successfully."

    status = snc.run_snc(identifiers=["ualberta"], description="", data_type="hashtag", time_frame="week", relations=[], es_index_name="ualberta")
    assert status == "Graph built successfully."

def test_local_file_import():
    file_content = {
                    "name": "example1",
                    "description": "This is another example JSON file",
                    "doc": [
                        {
                            "title": "Document 1",
                            "author": "John Smith",
                            "date": "2022-01-01",
                            "text": "This is the first document",
                            "content": "This is the first document"
                        },
                        {
                            "title": "Document 2",
                            "author": "Jane Doe",
                            "date": "2022-01-02",
                            "text": "This is the second document",
                            "content": "This is the second document"
                        }
                    ]
                }

    status = snc.import_from_json("testing", file_content, "Testing")
    assert status == "File Uplode Successful"
    file_content = {
                    "name": "example3",
                    "description": "Yet another example JSON file",
                    "doc": [
                        {
                            "name": "Person 1",
                            "likes": 1123,
                            "text": "This is the first Person tweet",
                            "description": "This is the first Person"
                        },
                        {
                            "name": "Person 2",
                            "likes": 1123,
                            "text": "This is the second Person tweet",
                            "description": "This is the second Person"
                        },
                        {
                            "name": "Person 3",
                            "likes": 123,
                            "text": "This is the third Person tweet",
                            "description": "This is the second Person"
                        }
                    ]
                }
    status = snc.import_from_json("testing", file_content, "Testing")
    assert status == "File Uplode Successful"

def test_create_delete_collection():

    status = snc.create_index_snc("testindex", "testdescription")
    assert status == "Create Index Successful"

    # status = snc.delete_index_snc("testindex")
    # assert status == "Delete Index Successful"

    # status = snc.create_index_snc("testindex")
    # assert status == "Create Index Successful"

    # status = snc.delete_index_snc("testindex")
    # assert status == "Delete Index Successful"

# # def test_tweet_data_type():

# #     status = snc.run_snc(identifiers=["nobelprize"], data_type="tweet", time_frame="week", relations=[], es_index_name="nobelprize")
# #     assert status == "Graph built successfully."


def test_pull_from_websearch():
    webpages = snc._pull_documents_from_search("Edmonton Oilders", "news", "en-CA", max_docs=5)
    assert len(webpages) > 0