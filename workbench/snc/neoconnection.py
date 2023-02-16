from neo4j import GraphDatabase

class NeoConnection:
    def __init__(self, uri, user, pwd):
        '''
        Class initialization. 
        Args:   uri - the url of the neo4j instance (e.g. http://localhost:7687)
                user - username for neo4j authentication
                pwd - password for neo4j authentication
        '''
        self.uri = uri
        self.user = user
        self.pwd = pwd
        self.db_conn = None
        self.transactions = []

        self.db_conn = GraphDatabase.driver(
            uri, auth=(self.user, self.pwd), encrypted=False
        )
        self.session = self.db_conn.session()

    def get_session(self):
        if self.session is None:
            raise Exception("Session not initialized.")
        return self.session

    def exec_query(self, query, get_result: bool=True, **query_params):
        '''
        Executes a query against neo4j database. If get_result is true, will return the response as a list.
        Args:   query - to be executed against neo4j db
                get_result - True if you wish to obtain the results of the query 
                            False if you do not need the results of the query (e.g. you wish to build a subgraph or projection - these operations do not have results)
        '''
        # Error handling
        if self.db_conn is None or self.session is None:
            raise Exception(
                "Connection not established... cannot execute transaction(s)!"
            )

        if get_result:
            response = None
            try:
                response = list(self.session.run(query, **query_params))
            except Exception as e:
                print(f"Query failed: {e}")

            return response
        else:
            try:
                self.session.run(query, **query_params)
            except Exception as e:
                print(f"Query failed: {e}")

    def close(self):
        if self.session is not None:
            self.session.close()
        if self.db_conn is not None:
            self.db_conn.close()
