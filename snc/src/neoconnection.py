from neo4j import GraphDatabase

class NeoConnection:
    def __init__(self, uri, user, pwd):
        self.uri = uri
        self.user = user
        self.pwd = pwd
        self.db_conn = None
        self.transactions = []

        try:
            self.db_conn = GraphDatabase.driver(
                uri, auth=(self.user, self.pwd), encrypted=False
            )
            self.session = self.db_conn.session()
        except Exception as err:
            print(f"Failed to establish a connection: {err}")

    def get_session(self):
        if self.session is None:
            raise Exception("Session not initialized.")
        return self.session

    def exec_query(self, query, getResult):
        # Error handling
        if self.db_conn is None or self.session is None:
            raise Exception(
                "Connection not established... cannot execute transaction(s)!"
            )

        if getResult:
            response = None
            try:
                response = list(self.session.run(query))
            except Exception as e:
                print(f"Query failed: {e}")

            return response
        else:
            try:
                self.session.run(query)
            except Exception as e:
                print(f"Query failed: {e}")

    def get_users(self):
        return self.exec_query(
            "MATCH (n:User) RETURN (n.username) AS username", getResult=True
        )

    def get_tweets(self):
        return self.exec_query(
            "MATCH (n:Tweet RETURN (n.id) AS tweetId", getResult=True
        )

    def run_pageRank(self, name, entities, rel, attribute):
        from pandas import DataFrame

        limit = 10

        # Create projection of data to run algorithms on
        query = f"""CALL gds.graph.project(
                    '{name}',
                    {entities},
                    '{rel}')"""
        self.exec_query(query, getResult=False)

        # Run pageRank algorithm
        query = f"""CALL gds.pageRank.stream('{name}')
                YIELD nodeId, score
                RETURN gds.util.asNode(nodeId).{attribute} as {attribute}, score
                ORDER BY score DESC
                LIMIT {limit}"""

        data = DataFrame([dict(_) for _ in self.exec_query(query, getResult=True)])
        # Display results
        length = 25
        print("-" * length, name, "-" * length, sep="")
        print(data.head(limit))
        print("=" * (2 * length + (len(name))))

        # Clean up
        query = f"""CALL gds.graph.drop('{name}')"""
        self.exec_query(query, getResult=False)

    def close(self):
        if self.session is not None:
            self.session.close()
        if self.db_conn is not None:
            self.db_conn.close()
