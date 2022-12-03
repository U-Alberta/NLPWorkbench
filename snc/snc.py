from datetime import datetime
from dateutil.relativedelta import relativedelta
import logging

import tweepy

from src.neoconnection import NeoConnection
from src.neomethods import extract_identifiers
from src.network_constructors import build_tweet_network, build_username_network
from src.rpc import create_celery
import src.config as config

celery = create_celery("snc")


@celery.task
def run_snc(data, data_type, time_frame):
    """
    A lot of the parts of this function are commented out as they were previously implemented to be ran from the console.
    Now, the data, type of data (username/tweet handles), and time frame (e.g. week, month, etc.) should be passed to an API endpoint
    within the workbench (via a POST request) which will then call this method and provide this data.

    Once this is fully implemented the commented out code will be deleted, it is just left as a reference for the time being.
    """

    logging.info("run snc")

    g_conn = NeoConnection(uri="bolt://snc-neo4j:7687", user="neo4j", pwd="snc123")
    client = tweepy.Client(bearer_token=config.BEARER_TOKEN)

    # data_options = ["Usernames", "Tweet IDs", "Skip data extraction"]
    # data_type, index = pick(options , "Please select the data which will serve as input for the network constructor: ", indicator=">")

    # time_options = ["Week", "Month", "3 Months"]
    # time_frame, index = pick(time_options , "Please select the desired time frame: ", indicator=">")
    start_date = None

    if time_frame == "week":  # week
        start_date = datetime.today() - relativedelta(weeks=1)
    elif time_frame == "month":  # month
        start_date = datetime.today() - relativedelta(months=1)
    elif time_frame == "3month":  # 3 months
        start_date = datetime.today() - relativedelta(months=3)
    else:  # other
        return "[-] Error: other time frame not implemented yet..."
    
    # print("[+] Extracting data and building network. This may take some time...")
    if data_type == "users":  # Build network from usernames
        # extract_identifiers(path='./data/usernames.txt', data=identifiers)
        build_username_network(client, data, start_date, g_conn)
    elif data_type == "tweets":  # Build network from tweet id's
        # extract_identifiers(path='./data/tweets.txt', data=identifiers)
        build_tweet_network(client, data, start_date, g_conn)

    """Page centrality algorithms -- will be implemented later (add option to run centrality algorithm in front-end, pass this value)"""
    # system('clear')
    # options = ["Yes", "No"]
    # option, index = pick(options, "\nDo you wish to run the page rank centrality algorithm on the network: ", indicator=">")

    # if(option == options[0]):
    #     g_conn.run_pageRank(name='annotatedOrganizations', entities=['Organization','Tweet'], rel='ANNOTATES', attribute='description')
    #     g_conn.run_pageRank(name='mentionedUsers', entities=['User','Tweet'], rel='MENTIONS', attribute='username')
    #     g_conn.run_pageRank(name='annotatedPlaces', entities=['Place','Tweet'], rel='ANNOTATES', attribute='description')
    #     input("\nPress enter to continue...")

    """Subgraph functionality -- todo: add option to build subgraph on a given entity"""
    # options = ["User", "Tweet", "No"]
    # usernames = [record['username'] for record in g_conn.get_users()]
    # while True:
    #     system('clear')
    #     option, index = pick(options, "\nDo you wish to build a subgraph on one of the given entities: ", indicator=">")

    #     if(option == options[2]):
    #         break
    #     elif(option == options[0]):                 # User subgraph
    #         username = input("Enter the username of an entity in the graph: ")
    #         if username not in usernames:
    #             input("[-] Error: there is no existing user with the username '{}'. Press enter to continue...".format(username))
    #         else:
    #             print("Paste the following code in the neo4j browser to obtain the desired subgraph: ")
    #             input(f'''
    #             MATCH (n:User{{username:"{username}"}})
    #             CALL apoc.path.subgraphNodes(n, {{labelFilter:'-User'}}) YIELD node
    #             RETURN node\n\nPress enter to continue...''')
    #     elif(option == options[1]):                 # Tweet subgraph
    #         input("not implemented yet...\n\nPress enter to continue...")

    g_conn.close()
    # print("\n[+] Program finished.")
    return "Graph built successfully."


def test_snc():
    print(run_snc(data=["NobelPrize"], data_type="users", time_frame="week"))


if __name__ == "__main__":
    celery.start(argv=["worker", "-l", "INFO", "--concurrency=1", "-Q", "snc"])
    # test_snc()
