from workbench import snc

def test_getting_user_tweets():
    status = snc.run_snc(identifiers=["NobelPrize"], data_type="user", time_frame="week", relations=[], es_index_name="test_index")
    assert status == "Graph built successfully."

def test_user_tweets_timeframe():
    status = snc.run_snc(identifiers=["NobelPrize"], data_type="user", time_frame="month", relations=[], es_index_name="test_index")
    assert status == "Graph built successfully."

    status = snc.run_snc(identifiers=["NobelPrize"], data_type="user", time_frame="3month", relations=[], es_index_name="test_index")
    assert status == "Graph built successfully."

    status = snc.run_snc(identifiers=["ualberta"], data_type="user", time_frame="week", relations=[], es_index_name="ualberta")
    assert status == "Graph built successfully."

def test_user_tweets_with_relations():
    status = snc.run_snc(identifiers=["ualberta"], data_type="user", time_frame="week", relations=["like"], es_index_name="ualberta")
    assert status == "Graph built successfully."

    status = snc.run_snc(identifiers=["ualberta"], data_type="user", time_frame="week", relations=["embed"], es_index_name="ualberta")
    assert status == "Graph built successfully."

    status = snc.run_snc(identifiers=["ualberta"], data_type="user", time_frame="week", relations=["follow"], es_index_name="ualberta")
    assert status == "Graph built successfully."

    status = snc.run_snc(identifiers=["ualberta"], data_type="user", time_frame="week", relations=["retweet"], es_index_name="ualberta")
    assert status == "Graph built successfully."

    status = snc.run_snc(identifiers=["ualberta"], data_type="user", time_frame="week", relations=["mention"], es_index_name="ualberta")
    assert status == "Graph built successfully."

def test_user_tweets_data_types():
    status = snc.run_snc(identifiers=["ualberta"], data_type="user", time_frame="week", relations=[], es_index_name="ualberta")
    assert status == "Graph built successfully."

    status = snc.run_snc(identifiers=["ualberta"], data_type="hashtag", time_frame="week", relations=[], es_index_name="ualberta")
    assert status == "Graph built successfully."

# def test_tweet_data_type():

#     status = snc.run_snc(identifiers=["nobelprize"], data_type="tweet", time_frame="week", relations=[], es_index_name="nobelprize")
#     assert status == "Graph built successfully."

if __name__ == '__main__':
    test_getting_user_tweets()