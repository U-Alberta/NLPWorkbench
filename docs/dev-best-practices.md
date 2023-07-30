## Locally Develop and Debug Frontend
The frontend can be completely separated from the backend. Let's say you already have a fully functioning backend running at `http://mybackend:12345` where `12345` is the port of the `api` service. and want to develop and debug only the frontend.

1. Go to `frontend/`
2. Create a file `.env.local` under `frontend/`, append `VITE_API="http://mybackend:12345"` to the file.
3. Run `npm install` to install frontend dependencies.
4. Run `npm run dev`. This will serve the frontend with **hot patching**, which means you don't have to restart or rebuild after making changes to the frontend.

After creating the `.env.local` file, you can also open the folder `frontend` in your favorite IDE such as WebStorm.

## Locally Develop and Debug Containers
When multiple instances of nlpworkbench is running, edit `.env` under the repository root (create one if it doesn't exist) to add:
```bash
API_PORT=12345 # specify a different port for api to avoid collision
FRONTEND_PORT=54321 # specify a different port for frontend to avoid collision
PROJECT_NAME="-dev-some-random-word" # define a unique name for the instance
```
Change the 3 variables according to your name.

When debugging you usually don't need to build and run all containers defined inside `docker-compose.dev.yml`. You can add `- debug` (or whatever name you like) to the `profiles` section of the containers you want to bring up in `docker-compose.dev.yml`. For example:

```yaml
services:
  api:
    ports:
      - "${API_PORT:-50050}:50050"
    build:
      dockerfile: ./build/Dockerfile.api
      target: ${COMPOSE_TARGET:-prod}
    environment:
      - RPC_BROKER=${RPC_BROKER:-redis://redis}
      - RPC_BACKEND=${RPC_BACKEND:-redis://redis}
      - BING_KEY=${BING_KEY}
    profiles:
      - non-gpu
      - debug # <--- This line
```

After that, when you run `docker compose -f docker-compose.dev.yml --profile debug up --build`, only the containers marked with `- debug` will be built and run.

## HTTP API Convention
We try to follow [RESTful](https://learn.microsoft.com/en-us/azure/architecture/best-practices/api-design) API style, where HTTP method and URL combined defines the operation.

URL uniquely identifies a resource (entity, collection, document, etc.). For example:

* `/entity/<entity_id>`
* `/collection/<collection_name>`
* `/collection/<collection_name>/doc/<doc_id>`

When doing processing on a resource, the name of the operation is part of the URL, for example: `/collection/<collection_name>/import_from_search` initiates an import operation on the collection with name `collection_name`.

For a URL identifying the same resource, different HTTP methods lead to different operations. For example for `/collection/<collection_name>`, `GET` is read-only and returns information about the collection. `DELETE` will delete the collection. `PUT` creates a collection with the name `<collection_name>`. For other operations that process a resource, such as batch processing or batch importing, `POST` is used.