This project was bootstrapped with [Create React App](https://github.com/facebook/create-react-app).

# About
A front-end UI for users to input either twitter handles or tweet ID's in order to construct and visualize a social network of the provided entities. All the necessary data & metadata is pulled from [Twitter's API](https://developer.twitter.com/en/docs/twitter-api) and formatted in order to be pushed to the graph database management system Neo4J. This in turn allows the user to not only visualize a subset of the data (and inspect areas of interest) but also to run graph algorithms to gain more insight behind certain networks (e.g. centrality algorithms). 
  
By building these graphs we are able to better answer questions such as:
1. which users and/or tweets have the most interaction/connectivity 
2. which persons, organizations, global entities, etc. are mentioned in a given network (entity extraction from tweets with embeddings)
3. how do narratives and emphases shift given certain social networks (gauged by running centrality algorithms)
4. and many other similar questions which are difficult to answer efficiently simply by browsing tweets 

Below is an example of a micro-network created by pulling only four users:
![graph_example](/uploads/e248acafcf68f819d25473215a3bdc5d/entire_graph.png)


