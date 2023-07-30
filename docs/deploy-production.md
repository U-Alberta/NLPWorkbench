On the host machine, prepare the folders for persisting data
```bash
mkdir /path/to/neo4j/data  # folder for storing neo4j data
mkdir /path/to/es/data  # folder for storing elasticsearch data
mkdir /path/to/sqlite/data  # folder for storing embeddings
touch /path/to/sqlite/data/embeddings.sqlite3 # database file for storing embeddings

mkdir -p /path/to/neo4j/certs/bolt/ # folder for storing neo4j certificates
cp /path/to/privkey.pem /path/to/neo4j/certs/bolt/private.key
cp /path/to/fullchain.pem /path/to/neo4j/certs/bolt/public.crt
cp /path/to/fullchain.pem /path/to/neo4j/certs/bolt/trusted/public.crt

# change permission to writable
chmod a+rwx /path/to/neo4j/data
chmod a+rwx /path/to/es/data
chmod a+rwx /path/to/sqlite/data/embeddings.sqlite3

chown -R 7474:7474 /path/to/neo4j/certs/
# change permissions of neo4j certificates following https://neo4j.com/docs/operations-manual/current/security/ssl-framework/#ssl-bolt-config
# just for example,
chmod 0755 /path/to/neo4j/certs/bolt/private.key
```

Modify `docker-compose.yml` file to mount the volumes to the correct locations (the folders you created above). Search for `volumes:` or `# CHANGE THIS` in `docker-compose.yml` and replace `source: ` with the correct path.

**This step may not be needed. Open `workbench-url/kibana` in browser first to see if kibana is working.** Follow this [document](https://www.elastic.co/guide/en/kibana/current/docker.html) to set elasticsearch passwords and generate enrollment tokens for kibana.
```bash
# set password for user elastic
docker exec -it nlp-workbench-elasticsearch-1 /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic -i
# set password for user kibana_system
docker exec -it nlp-workbench-elasticsearch-1 /usr/share/elasticsearch/bin/elasticsearch-reset-password -u kibana_system -i
# generate an enrollment token for kibana
docker exec -it nlp-workbench-elasticsearch-1 /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana
```
Open kibana in a browser and use the enrollment token to set up kibana.


Modify the port mapping in `docker-compose.yml` file under `services -> frontend -> ports` to change the exposed port. The current one is 8080, which means `http://localhost:8080` is the url for the workbench.


Clone the repositories and build docker images:
```bash
# build images
docker compose --profile non-gpu --profile gpu build
# run
docker compose --profile non-gpu --profile gpu up
```
