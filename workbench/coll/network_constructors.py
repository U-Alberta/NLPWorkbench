from tweepy import Paginator
from .neoconnection import NeoConnection
from .neomethods import create_follows_relation, create_tweet_relation


def build_tweet_network(client, tweet_ids, start_date, connection: NeoConnection):
    all_usernames = []
    session = connection.get_session()

    for tweet_id in tweet_ids:
        tweet = client.get_tweet(
            id=tweet_id,
            tweet_fields=["author_id", "created_at", "public_metrics", "entities"],
        )
        if tweet.data is None:
            continue

        username = [client.get_user(id=tweet.data["author_id"]).data["username"]]
        if username[0] not in all_usernames:
            all_usernames.append(username[0])
            build_username_network(client, username, start_date, connection)

        tweet_query = connection.exec_query(
            f"""MATCH (n:Tweet{{id: {tweet_id}}}) RETURN (n)""", getResult=True
        )

        if len(tweet_query):  # Tweet already exists within neo4j
            # Update volatile data
            session.run(
                "MATCH (t:Tweet {id: $id})"
                "SET t.likes = $like_count"
                "t.retweets: $retweet_count"
                "t.replies: $reply_count",
                id=tweet_id,
                like_count=tweet.data["public_metrics"]["like_count"],
                retweet_count=tweet.data["public_metrics"]["retweet_count"],
                reply_count=tweet.data["public_metrics"]["reply_count"],
            )
        else:
            # Import tweet into neo4j
            tweet_id = tweet.data["id"]
            text = str(tweet.data["text"]).replace('"', "'")
            session.run(
                "MERGE (u:User {username: $username})"
                "MERGE (t:Tweet {id: $id, author_id: $author_id, created_at: $created_at, likes: $likes, retweets: $retweets, replies: $replies, text: $text})"
                "CREATE (u)-[:AUTHORED]->(t)",
                username=username,
                id=tweet_id,
                author_id=tweet.data["author_id"],
                created_at=tweet.data["created_at"],
                likes=tweet.data["public_metrics"]["like_count"],
                retweets=tweet.data["public_metrics"]["retweet_count"],
                replies=tweet.data["public_metrics"]["reply_count"],
                text=text,
            )
            # Push data regarding mentioned users/people/places
            if "entities" in tweet.data:
                if "mentions" in tweet.data["entities"]:
                    for user in tweet.data["entities"]["mentions"]:
                        session.run(
                            "MERGE (u:User {username: $username, id: $id}"
                            "MERGE (t:Tweet {id: $tweet_id})"
                            "MERGE (t)-[:MENTIONS]->(u)",
                            username=user["username"],
                            id=user["id"],
                            tweet_id=tweet_id,
                        )

                if "annotations" in tweet.data["entities"]:
                    for annotation in tweet.data["entities"]["annotations"]:
                        transaction = "MERGE (a:{} {{description: $desc}})\
                                       MERGE (t:Tweet {{id: $id}})\
                                       MERGE (t)-[:ANNOTATES {{probability: $probability}}]->(a)".format(
                            annotation["type"]
                        )
                        session.run(
                            transaction,
                            desc=annotation["normalized_text"],
                            id=tweet_id,
                            probability=annotation["probability"],
                        )


def build_username_network(client, usernames, start_date, connection: NeoConnection):
    session = connection.get_session()

    for username in usernames:
        user = client.get_user(
            username=username,
            user_fields=[
                "created_at",
                "description",
                "location",
                "protected",
                "public_metrics",
            ],
        )
        if user.data is None:
            continue

        user_query = connection.exec_query(
            f"""MATCH (n:User{{id: {user.data['id']}}}) RETURN (n)""", getResult=True
        )
        if len(user_query):  # User already exists in neo4j
            # Update volatile data
            session.run(
                "MATCH (n:User{id: $id})"
                "SET n.followers = $followers, n.following = $following, n.tweet_count = $tweet_count",
                id=user.data["id"],
                followers=user.data["public_metrics"]["followers_count"],
                following=user.data["public_metrics"]["following_count"],
                tweet_count=user.data["public_metrics"]["tweet_count"],
            )
        else:
            # Import user into neo4j
            session.run(
                "CREATE (:User{\
                            username: $username,\
                            id: $id,\
                            description: $desc,\
                            name: $name,\
                            followers: $followers,\
                            following: $following,\
                            tweet_count: $tweet_count,\
                            created_on: $created_on})",
                username=username,
                id=user.data["id"],
                desc=user.data["description"],
                name=user.data["name"],
                followers=user.data["public_metrics"]["followers_count"],
                following=user.data["public_metrics"]["following_count"],
                tweet_count=user.data["public_metrics"]["tweet_count"],
                created_on=str(user.data["created_at"])[0:10],
            )

            # Import user's followers
            followers = client.get_users_followers(id=user.data["id"])
            for follower in followers.data:
                create_follows_relation(follower, username, connection)

            # Import user's recent tweets (if existent)
            for recent_tweets in Paginator(
                client.get_users_tweets,
                id=user.data["id"],
                start_time=start_date,
                max_results=100,
                tweet_fields=["author_id", "created_at", "public_metrics", "entities"],
            ):
                if recent_tweets.data:
                    for tweet in recent_tweets.data:
                        # Add tweet and authored by relation in neo4j
                        tweet_id = tweet["id"]
                        text = str(tweet["text"]).replace('"', "'")
                        session.run(
                            "MERGE (u:User{username: $username})"
                            "MERGE (t:Tweet{\
                                        id: $tweet_id,\
                                        author_id: $author_id,\
                                        created_at: $created_at,\
                                        likes: $likes,\
                                        retweets: $retweets,\
                                        replies: $replies,\
                                        text: $text})"
                            "CREATE (u)-[:AUTHORED]->(t)",
                            username=username,
                            tweet_id=tweet_id,
                            author_id=tweet["author_id"],
                            created_at=tweet["created_at"],
                            likes=tweet["public_metrics"]["like_count"],
                            retweets=tweet["public_metrics"]["retweet_count"],
                            replies=tweet["public_metrics"]["reply_count"],
                            text=text,
                        )
                        # Push data regarding mentioned users/people/places
                        if "entities" in tweet:
                            if "mentions" in tweet["entities"]:
                                for user in tweet["entities"]["mentions"]:
                                    session.run(
                                        "MERGE (u:User {username: $username, id: $id})"
                                        "MERGE (t:Tweet {id: $tweet_id})"
                                        "MERGE (t)-[:MENTIONS]->(u)",
                                        username=user["username"],
                                        id=user["id"],
                                        tweet_id=tweet_id,
                                    )

                            if "annotations" in tweet["entities"]:
                                for annotation in tweet["entities"]["annotations"]:
                                    transaction = "MERGE (a:{} {{description: $desc}})\
                                                   MERGE (t:Tweet {{id: $id}})\
                                                   MERGE (t)-[:ANNOTATES {{probability: $probability}}]->(a)".format(
                                        annotation["type"]
                                    )
                                    session.run(
                                        transaction,
                                        desc=annotation["normalized_text"],
                                        id=tweet_id,
                                        probability=annotation["probability"],
                                    )

                        # Add likes/retweets in neo4j
                        # likes    = client.get_liking_users(id=tweet['id'])
                        # retweets = client.get_retweeters(id=tweet['id'])
                        # if likes.data:
                        # for tmp_user in likes.data:
                        # create_tweet_relation(tmp_user, tweet_id, 'LIKED', connection)
                        # if retweets.data:
                        # for tmp_user in retweets.data:
                        # create_tweet_relation(tmp_user, tweet_id, 'RETWEETED', connection)
