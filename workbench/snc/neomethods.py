from .neoconnection import NeoConnection
from tweepy import Paginator
from elasticsearch import Elasticsearch
from .elasticmethods import merge_doc

MAX_RESULTS = 100 # TODO: change to an appropriate value

def get_users(neo_connection: NeoConnection):
    '''
    Returns a list with the usernames of all users which are existent within the passed neo4j instance.
    '''
    return neo_connection.exec_query("MATCH (n:User) RETURN (n.username) AS username", get_result=True)

def get_tweets(neo_connection: NeoConnection):
    '''
    Returns a list with the IDs of all tweets which are existent within the passed neo4j instance.
    '''
    return neo_connection.exec_query("MATCH (n:Tweet) RETURN (n.id) AS tweetId", get_result=True)

def update_tweet(neo_session, tweet_data):
    '''
    Updates a tweet which already exists within the neo4j session provided with the data passed (through tweet_data).
    Args:   neo_session - active neo4j session
            user_data - object containing the data which is to be updated (volatile data such as like count, reply count, etc.)
    '''
    neo_session.run("MATCH (t:Tweet {id: $id})"
                "SET t.likes = $like_count, t.retweets = $rt_count, t.replies = $reply_count",
                id=tweet_data['id'], 
                like_count=tweet_data['public_metrics']['like_count'],
                rt_count=tweet_data['public_metrics']['retweet_count'],
                reply_count=tweet_data['public_metrics']['reply_count']
    )

def update_user(neo_session, user_data):
    '''
    Updates a user who already exists within the neo4j session provided with the data passed (through user_data).
    Args:   neo_session - active neo4j session
            user_data - object containing the data which is to be updated (volatile data such as followers, following, etc.)
    '''
    # Updates a user who already exists within the neo4j database
    neo_session.run("MATCH (n:User{id: $id})"
                "SET n.followers = $followers, n.following = $following, n.tweet_count = $tweet_count",
                id=user_data['id'], 
                followers=user_data['public_metrics']['followers_count'], 
                following=user_data['public_metrics']['following_count'],
                tweet_count=user_data['public_metrics']['tweet_count']
    )

def tweet_exists(neo_connection: NeoConnection, tweet_id):
    '''
    Checks if a tweet already exists within the provided neo4j connection.
    Returns:    True if tweet exists
                False otherwise
    '''
    if len(neo_connection.exec_query(
        'MATCH (n:Tweet) WHERE n.id=$nid RETURN (n)',
        get_result=True,
        nid=tweet_id
    )):
        return True
    return False

def user_exists(neo_connection: NeoConnection, user_id):
    '''
    Checks if a user already exists within the provided neo4j connection.
    Returns:    True if user exists
                False otherwise
    '''
    if len(neo_connection.exec_query(
        'MATCH (n:User) WHERE n.id=$nid RETURN (n)',
        get_result=True,
        nid=user_id
    )):
        return True
    return False

def create_tweet(neo_connection: NeoConnection, tweet_data, relations: list, es_index_name):
    '''
    Creates a new tweet within the neo4j session provided.
    Args:   neo_connection - connection to neo4j instance
            tweet_data - object representing the tweet which is to be added to neo4j
            relations - a list representing the desired relations to be extracted 
                       (i.e. if we wish to pull embedded entities within tweets then 'entities' must be an element within relations)
            es_index_name - the name of the index within elastic search to which data of the tweet will be pushed
    '''
    if tweet_exists(neo_connection, tweet_data['id']):
        return

    # Push tweet to database 
    formatted_text = str(tweet_data['text']).replace('"', "'")
    neo_connection.get_session().run(
        "CREATE (t:Tweet{\
        id: $tweet_id,\
        author_id: $author_id,\
        created_at: $created_at,\
        likes: $likes,\
        retweets: $retweets,\
        replies: $replies,\
        text: $text})",
        tweet_id = tweet_data['id'], 
        author_id = tweet_data['author_id'], 
        created_at = tweet_data['created_at'],
        likes = tweet_data['public_metrics']['like_count'],
        retweets = tweet_data['public_metrics']['retweet_count'],
        replies = tweet_data['public_metrics']['reply_count'], 
        text = formatted_text
    )

    # Link tweet to aux node
    neo_connection.get_session().run(
        "MERGE (t:Tweet {id: $tweet_id})"
        "MERGE (a:Auxiliary {name: $index_name})"
        "MERGE (t)-[:BELONGS]->(a)",
        tweet_id = tweet_data['id'], index_name = es_index_name
    )

    # Push data regarding annotated entities (if specified in relations parameter)
    if "entities" in tweet_data:
        if ("mentions" in tweet_data["entities"] and "mention" in relations):
            for user in tweet_data["entities"]["mentions"]:
                neo_connection.get_session().run(
                    "MERGE (u:User {username: $username, id: $id})"
                    "MERGE (t:Tweet {id: $tweet_id})"
                    "MERGE (t)-[:MENTIONS]->(u)",
                    username = user['username'], 
                    id = user['id'], 
                    tweet_id = tweet_data['id']
                )

        if ("annotations" in tweet_data["entities"] and "embed" in relations):
            for annotation in tweet_data["entities"]["annotations"]:
                transaction = "MERGE (a:{} {{description: $desc}})\
                                MERGE (t:Tweet {{id: $id}})\
                                MERGE (t)-[:ANNOTATES {{probability: $probability}}]->(a)".format(annotation['type'])
                neo_connection.get_session().run(
                    transaction,
                    desc = annotation['normalized_text'], 
                    id = tweet_data['id'], 
                    probability = annotation['probability']
                )

def create_user(neo_connection:NeoConnection, tweepy_client, es_client: Elasticsearch, user_data, start_date, relations: list, es_index_name):
    '''
    Creates a new user within the neo4j session provided. Also pulls all data relating to the user (e.g. tweets, followers, if so specified by relations argument)
    Args:   neo_connection - connection to neo4j instance
            tweepy_client - twitter API v2 client
            es_client - elastic search client
            user_data - object representing the user to be added to neo4j
            start_date - the oldest timestamp from which user's tweets will be provided (i.e. if 1 day then only tweets within the last 24hrs are pulled)
            relations - list representing the relations to extract (e.g. ['follows','likes'] to only pull the followers and likers of that user or their tweets, respectively)
            es_index_name - the name of the index within elastic search to which data of the user will be pushed
    '''
    if user_exists(neo_connection, user_data['id']):
        return

    # Import user
    neo_connection.get_session().run(
        "CREATE (:User{\
        username: $username,\
        id: $id,\
        description: $desc,\
        name: $name,\
        followers: $followers,\
        following: $following,\
        tweet_count: $tweet_count,\
        created_on: $created_on})",
        username = user_data['username'], 
        id = user_data['id'], 
        desc = user_data['description'], 
        name = user_data['name'],
        followers = user_data['public_metrics']['followers_count'], 
        following = user_data['public_metrics']['following_count'],
        tweet_count = user_data['public_metrics']['tweet_count'], 
        created_on = str(user_data['created_at'])[0:10]
    )

    # Link user to aux node
    neo_connection.get_session().run(
        "MERGE (u:User {id: $user_id})"
        "MERGE (a:Auxiliary {name: $index_name})"
        "MERGE (u)-[:BELONGS]->(a)",
        user_id = user_data['id'], index_name = es_index_name
    )

    # Import followers
    if "follow" in relations:
        for followers in Paginator(
            tweepy_client.get_users_followers,
            id=user_data['id'],
            max_results=MAX_RESULTS
        ):
            if followers.data:
                for follower in followers.data:
                    create_follower(neo_connection, follower, user_data['id'])

    # Import tweets
    for tweets in Paginator(
                tweepy_client.get_users_tweets,
                id=user_data["id"],
                start_time=start_date,
                max_results=MAX_RESULTS,
                tweet_fields=["author_id", "created_at", "public_metrics", "entities"],
    ):
        if tweets.data:
            for tweet in tweets.data:
                create_tweet(neo_connection, tweet, relations, es_index_name)
                create_author(neo_connection, user_data['id'], tweet['id'])

                # Format data for ES ingestion
                doc = {
                    'type': 'tweet',
                    'id': tweet.data['id'],
                    'created_on': tweet.data['created_at'],
                    'likes': tweet.data['public_metrics']['like_count'],
                    'retweets': tweet.data['public_metrics']['retweet_count'],
                    'replies': tweet.data['public_metrics']['reply_count'],
                    'text': tweet.data['text'],
                    'api_resp': tweet.data
                }

                # Merge into elastic search (handles both update or creation)
                merge_doc(
                    client=es_client, 
                    index_name=es_index_name, 
                    doc_id=doc['id'], 
                    doc_data=doc
                )

                # Import likes/retweets
                if "like" in relations:
                    for likes in Paginator(
                        tweepy_client.get_liking_users,
                        id=tweet['id'],
                        max_results=MAX_RESULTS
                    ):
                        if likes.data:
                            for liking_user in likes.data:
                                create_tweet_relation(neo_connection, liking_user, tweet['id'], 'LIKED')

                if "retweet" in relations:
                    for retweets in Paginator(
                        tweepy_client.get_retweeters(id=tweet['id']),
                        id=tweet['id'],
                        max_results=MAX_RESULTS
                    ):
                        if retweets.data:
                            for retweeter in retweets.data:
                                create_tweet_relation(neo_connection, retweeter, tweet['id'], 'RETWEETED')

def create_author(neo_connection: NeoConnection, user_id, tweet_id):
    '''
    Creates 'AUTHORED' relationship between a user and a tweet.
    Args:   neo_connection - connection to neo4j instance
            user_id - the ID of the user (or author, in this case)
            tweet_id - the ID of the tweet to be authored
    '''
    if (not user_exists(neo_connection, user_id) or not tweet_exists(neo_connection, tweet_id)):
        raise Exception("User/Tweet non-existent - failed to create author relation")

    neo_connection.get_session().run(
        "MERGE (u:User{id: $user_id})"
        "MERGE (t:Tweet{id: $tweet_id})"
        "MERGE (u)-[:AUTHORED]->(t)",
        user_id=user_id, tweet_id=tweet_id
    ) 
def create_tweet_relation(neo_connection: NeoConnection, user, tweet_id, relation):
    '''
    Creates whichever relation is passed between the user and tweet provided.
    Args:   neo_connection - connection to neo4j instance
            user - object representing the user in question
            tweet_id - the id of the tweet in question
    '''
    username = str(user['username']).replace('"', "")
    name = str(user['name']).replace('"', "")

    if user_exists(neo_connection, user['id']):
        transaction = "MERGE (p:User {{username: $username}}), (t:Tweet {{id: $id}})\
                       MERGE (p)-[:{}]->(t)".format(relation)
        neo_connection.get_session().run(
            transaction,
            username=username, id=tweet_id, relation=relation
        )
    else:
        transaction = "MERGE (p:Follower {{username: $username, id: $id, name: $name}})\
                       MERGE (t:Tweet {{id: $tweet_id}})\
                       MERGE (p)-[:{}]->(t)".format(relation)
        neo_connection.get_session().run(
            transaction, 
            username=username, id=user['id'], name=name, tweet_id=tweet_id
        )

def create_follower(neo_connection: NeoConnection, follower, user_id):
    '''
    Creates the 'FOLLOWS' relationship between the follower and user provided.
    Args:   neo_connection - connection to neo4j instance
            follower - object representing the follower (who will follow the user)
            user_id - the id of the user to be followed
    '''
    follower_username = str(follower['username']).replace('"', "")
    follower_name = str(follower['name']).replace('"', "")

    if user_exists(neo_connection, follower['id']):     # Follower exists as a User within graph
        neo_connection.get_session().run(
            "MERGE (f:User {id: $f_id})"
            "MERGE (u:User {id: $user_id})"
            "MERGE (f)-[:FOLLOWS]->(u)",
            f_id=follower['id'], user_id=user_id 
        ) 
    else:
        neo_connection.get_session().run(
            "MERGE (f:Follower {username: $f_username, id: $f_id, name: $f_name})"
            "MERGE (u:User {id: $user_id})"
            "MERGE (f)-[:FOLLOWS]->(u)",
            f_username=follower_username, f_id=follower['id'], f_name=follower_name,
            user_id=user_id
        )

def run_pagerank(neo_connection: NeoConnection, name, entities: list, rel, attribute):
    '''
    Creates a projection with the entities/relationships specified in arguments, then runs the
    built-in pagerank algorithm on said projection within neo4j. Results are printed to the command line.

    Args:   neo_connection - connection to neo4j instance
            name - name of newly created projection graph
            entities - a list of the entities to project e.g. ['Organizations', 'Tweets']
            rel - relationship to project e.g. 'MENTIONS' or 'ANNOTATES'
            attribute - the attribute which will be used to identify the entities after pagerank is executed 
                        (e.g. username if you wish to see user's usernames, or perhaps description to see the details of ranked organizations)
    '''

    limit = 10

    # Create projection of passed entities/relationships
    neo_connection.get_session().run(
        f'''CALL gds.graph.project(
                '{name}', 
                {entities},
                '{rel}'
            )'''
    )

    # Run pageRank algorithm
    query = f'''CALL gds.pageRank.stream('{name}')
                YIELD nodeId, score
                RETURN gds.util.asNode(nodeId).{attribute} as {attribute}, score
                LIMIT {limit}
            '''
    data = [dict(_) for _ in neo_connection.exec_query(query, get_result=True)]

    # Display results (CLI)
    # length = 25
    # print("-" * length, name, "-" * length, sep="")
    # print(data.head(limit))
    # print("=" * (2 * length + (len(name))))

    # Clean up
    neo_connection.get_session().run(
        f'''CALL gds.graph.drop('{name}')'''
    )

    return data

def get_subgraph_query(neo_connection: NeoConnection, username):
    '''
    NOTE: this function was implemented for CLI interaction 

    Builds a cypher query which can be pasted in neo4j browser to analyze areas/users of interest.
    Args:   neo_connection - connection to neo4j instance
            username - the username of the entity on which to build a subgraph
    Returns:    the query to be executed in neo4j browser if user exists
                None otherwise (i.e. the user does not exist)
    '''
    all_usernames = [record['username'] for record in neo_connection.get_users()]
    username = input("Enter the username of an entity in the graph: ")
    if username not in all_usernames:
        input("[-] Error: there is no existing user with the username '{}'. Press enter to continue...".format(username))
        return None
    else:
        return f'''Paste the following code in the neo4j browser to obtain the desired subgraph:
                    MATCH (n:User{{username:"{username}"}})
                    CALL apoc.path.subgraphNodes(n, {{labelFilter:'-User'}}) YIELD node
                    RETURN node\n\nPress enter to continue...'''