from .neoconnection import NeoConnection

def create_tweet_relation(user, tweet_id, relation, connection: NeoConnection):
    session = connection.get_session()
    username = str(user["username"]).replace('"', "")
    name = str(user["name"]).replace('"', "")

    session.run("MERGE (:Follower {username: $username, user_id: $id, name: $name)",
                username = username, id = user['id'], name = name
    )
    session.run("MATCH (p:Follower {username: $username}), t(Tweet {id: $id})"
                "CREATE (p)-[:$relation]->(t)",
                username = username, id = tweet_id, relation = relation
    )
    session.run("MATCH (p:User {username: $username}), (t:Tweet {id: $id})"
                "CREATE (p)-[:$relation]->(t)",
                username = username, id = tweet_id, relation = relation
    )

def create_follows_relation(user, main_username, connection: NeoConnection):
    session = connection.get_session()
    username = str(user["username"]).replace('"', "")
    name = str(user["name"]).replace('"', "")

    session.run("MERGE (:Follower {username: $username, id: $id, name: $name})",
                username = username, id = user['id'], name = name
    )
    session.run("MATCH (p1:Follower {username: $username}), (p2:User {username: $main_username})"
                "CREATE (p1)-[:FOLLOWS]->(p2)",
                username = username, main_username = main_username
    )
    session.run("MATCH (p1:User {username: $username}), (p2:User {username: $main_username})"
                "CREATE (p1)-[:FOLLOWS]->(p2)",
                username = username, main_username = main_username
    )

def extract_identifiers(*, path: str, data: list):
    # Extracts the id's provided at the given path. Assumes each id is seperated by a newline character.
    #
    # Args:     path - path to file containing user(s)
    #           data - list to which extracted users/ids will be pushed to
    from os.path import exists

    while True:
        if exists(path):
            # Read all id's from file
            with open(path) as fin:
                while True:
                    line = fin.readline()
                    if not line:
                        break
                    else:
                        data.append(line.rstrip())
            break
        else:
            print("[-] Error: input file does not exist.")
