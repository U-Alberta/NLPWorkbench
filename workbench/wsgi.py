"""
The Flask web service
This file only contains route handles that:
  * find the article from the requested es collection, store it in g.doc
  * run actual tools implemented in api_impl.py
  * format and return the result
  * return error message to end user, if any

Implementations of model calls, whose results should be cached, are in api_impl.py
"""

import random
import re
import json

from celery import chain as celery_chain, group as celery_group, Signature
from flask import Flask, Blueprint, jsonify as flask_jsonify, request, g, current_app
from flask_cors import CORS
from neo4j import GraphDatabase

from .config import Config
from .utils import es_request, dictify, RequestError
from .bing_search import BingAPIError
from .coll import collection_api as collection_api_impl
from . import background, api_impl


neo4j = GraphDatabase.driver(Config.neo4j_url, auth=Config.neo4j_auth)
doc_api = Blueprint("doc_api", __name__, url_prefix="/collection")
app = Blueprint("root", __name__)


def create_app():
    flask_app = Flask(__name__)
    flask_app.register_blueprint(app)
    flask_app.register_blueprint(doc_api)
    flask_app.register_error_handler(500, handle_internal_error)
    CORS(flask_app, supports_credentials=True)
    return flask_app


def jsonify(obj):
    return flask_jsonify(dictify(obj))


@doc_api.before_request
def verify_collection_and_load_article():
    doc_id = None
    if request.view_args is not None:
        doc_id = request.view_args.get("doc_id")
        collection = request.view_args.get("collection")
    if doc_id in ("_random", "_import_from_url"):
        return "Invalid Document ID", 401
    if collection in ("_entity", Config.es_entity_collection, Config.es_log_index_name):
        return "Invalid Collection", 401
    if collection is not None:
        collection: str
        if (
            not re.match(r"^[a-z0-9-_+]+$", collection)
            or collection.startswith("_")
            or collection.startswith("-")
            or len(collection) == 0
            or len(collection) > 255
        ):
            return "Invalid Collection Name", 401
        if request.method not in ("PUT", "OPTIONS"):
            available_collections = api_impl.list_collections()
            if collection not in available_collections:
                return "Collection Not Found", 404
            g.collection = collection
    if doc_id is not None and not doc_id.startswith("WEB-") and collection is None:
        # if import an article from web, collection is not specified
        return "Collection Must Be Specified", 401
    # load article
    if doc_id is None or request.method in ("PUT", "OPTIONS"):
        return
    doc = api_impl.get_doc(doc_id)
    if doc is None:
        return "Document Not Found", 404
    g.doc = doc
    g.bypass_cache = request.args.get("bypass_cache", False) is not False


@app.route("/")
def hello():
    return "It's working!"


@doc_api.route("/<collection>/doc/_random")
def api_random_article(collection):
    article = api_impl.get_random_article()
    if not article:
        return "Collection is empty", 404
    return jsonify(article)


@doc_api.route("/<collection>/doc/_import_from_url", methods=["POST"])
def api_import_article(collection):
    # import article from url
    url = request.json["url"]
    try:
        article = api_impl.download_article_from_web(url)
    except:
        return "Failed to retrieve / parse article.", 400
    collection_api_impl.import_from_json(
        collection, {"doc": [article]}, source=f"Web page: {url}"
    )
    return jsonify(article)


@doc_api.route("/<collection>/doc/<doc_id>")
def api_pull_article(collection, doc_id):
    doc = {}
    for k in ("title", "author", "text", "url", "id"):
        if k in g.doc:
            doc[k] = g.doc[k]
    if "text" not in doc and "content" in g.doc:
        doc["text"] = g.doc["content"]
    if request.args.get("tokenize", False):
        api_impl.tokenize()
        doc["sentences"] = g.sentences
    if request.args.get("skip_text", False):
        del doc["text"]
    return doc


@doc_api.route("/<collection>/doc/<doc_id>/ner")
def api_run_ner(collection, doc_id):
    ner_output = api_impl.get_ner()
    # non-entity tokens are wrapped as a dict {"text": token}
    # for compatibility with es.
    # we need to unwrap them to be used in the frontend
    ner_output = [
        [x["text"] if "text" in x else x for x in sent] for sent in ner_output
    ]
    return flask_jsonify(ner_output)


@doc_api.route("/<collection>/doc/<doc_id>/link/<int:sent_idx>/<int:mention_idx>")
def api_run_linker(collection, doc_id, sent_idx, mention_idx):
    current_app.logger.info("api_run_linker")
    paragraph = api_impl.get_ner()
    if sent_idx < 0 or sent_idx >= len(paragraph):
        return "Sentence index out of bounds", 400
    sentence = paragraph[sent_idx]
    if mention_idx < 0 or mention_idx >= len(sentence):
        return "Mention index out of bounds", 404
    """
    FIXME: type check is broken with RPC.
    For a class C, local C and remote C are not equal.
    """
    # mention = sentence[mention_idx]
    # if not type(mention) == Coreference and not type(mention) == EntityMention:
    #    return "Mention is not an entity", 400
    candidates = api_impl.get_linker_output(sent_idx, mention_idx)
    return jsonify(candidates)


@app.route("/entity/<entity_id>/attributes")
def api_entity_attributes(entity_id):
    query = (
        "MATCH (e: Entity) WHERE e.entityId = $entity_id RETURN properties(e) AS attrs"
    )
    with neo4j.session() as session:
        row = session.run(query, parameters={"entity_id": entity_id}).single()
        if row is None:
            return "Entity Not Found", 404
        attrs = row["attrs"]
        for k in list(attrs.keys()):
            if k in ("alias", "name", "desc", "wikilink", "entityId"):
                del attrs[k]
            elif type(attrs[k]) != list:
                del attrs[k]
        return jsonify([{"attribute": k, "value": v} for k, v in attrs.items()])


@app.route("/entity/<entity_id>/description")
def api_entity_descriptions(entity_id):
    with neo4j.session() as session:
        desc = ""
        row = session.run(
            "MATCH (e: Entity) -[:WIKI_ABSTRACT]-> (wiki: WikiAbstract) WHERE e.entityId = $entity_id RETURN wiki.abstract AS abstract",
            entity_id=entity_id,
        ).single()
        if row:
            desc = "(Wikipedia) " + row["abstract"]
        if not desc:
            row = session.run(
                "MATCH (e: Entity) WHERE e.entityId = $entity_id RETURN e.desc AS desc",
                entity_id=entity_id,
            ).single()
            if row:
                desc = row["desc"]
                if type(desc) == list:
                    desc = desc[0]
                desc = "(Wikidata) " + desc
        return {"entity_id": entity_id, "description": desc}


@doc_api.route("/<collection>/doc/<doc_id>/semantic")
def api_semantic_parse_document(collection, doc_id):
    return jsonify(api_impl.semantic_parse_document())


@doc_api.route("/<collection>/doc/<doc_id>/person_relation")
def api_extract_person_relations(collection, doc_id):
    return flask_jsonify(api_impl.extract_person_relations())


@doc_api.route("/<collection>/doc/<doc_id>/sentiment")
def api_analyze_sentiment(collection, doc_id):
    return flask_jsonify(api_impl.analyze_sentiment())


@doc_api.route("/<collection>/doc/<doc_id>/relation")
def api_relation_extraction(collection, doc_id):
    return flask_jsonify(api_impl.extract_relations())


@doc_api.route("/<collection>/doc/<doc_id>/classify")
def api_crime_classify(collection, doc_id):
    return flask_jsonify(api_impl.run_crime_classifier())


@doc_api.route("/<collection>", methods=["DELETE"])
def api_delete_collection(collection):
    collection_api_impl.delete_index(collection)
    return collection, 204


@doc_api.route("/<collection>", methods=["PUT"])
def api_create_index(collection):
    current_app.logger.info("api_create_index")
    description = request.json.get("description")
    collection_api_impl.create_index(collection, description)
    return collection, 201


@doc_api.route("/")
def api_get_indexes():
    return flask_jsonify(api_impl.list_collections(detailed="detailed" in request.args))


@doc_api.route("/<collection>/uploadfile", methods=["POST"])
def api_uplode_file(collection):
    es_index = collection

    file = request.files["file"]
    json_data = file.read().decode("utf-8")
    data_dict = json.loads(json_data)

    if not data_dict.get("doc"):
        return "`doc` field of the JSON must be a non-empty array of documents", 401

    for doc in data_dict["doc"]:
        if not isinstance(doc.get("text"), str):
            return "Each document must contain a string field `text`", 401

    response = collection_api_impl.import_from_json.delay(
        es_index_name=es_index, file_content=data_dict
    ).get()
    result = flask_jsonify(response)
    return result, 201


@doc_api.route("/<collection>/log")
def api_read_log(collection):
    es_index_name = collection
    response = collection_api_impl.get_index_log(es_index_name)
    result = jsonify(response)
    return result


def _validate_import_search_request():
    # validate request
    api_key = request.headers.get("X-Bing-API-Key")
    if api_key is None:
        api_key = Config.default_bing_api_key
    if not api_key:
        # Unauthorized if no key is present
        return (
            "X-Bing-API-Key header missing and no default key is provided in the server.",
            403,
        )
    g.bing_api_key = api_key

    payload = request.json
    for key in ("query", "region", "mediaType", "freshness", "maxSize"):
        if not payload.get(key):
            return f"Missing parameter: {key}", 400
    if payload["freshness"] == "Custom" and "dateRange" not in payload:
        return "Missing parameter: dateRange", 400
    if payload["mediaType"] not in ("webpage", "news"):
        return "Invalid media type.", 400


@app.route("/search_preview", methods=["POST"])
def api_search_preview():
    err = _validate_import_search_request()
    if err:
        return err
    payload = request.json

    payload["dateRange"] = [x[:10] for x in payload["dateRange"]]  # format: YYYY-MM-DD
    try:
        if payload["mediaType"] == "news":
            resp = api_impl.preview_bing_news_search(
                payload["query"],
                payload["region"],
                g.bing_api_key,
                payload["newsCategory"],
                payload["freshness"],
            )
        else:
            resp = api_impl.preview_bing_webpage_search(
                payload["query"],
                payload["region"],
                g.bing_api_key,
                payload["freshness"],
                start_date=payload["dateRange"][0],
                end_date=payload["dateRange"][1],
            )
    except BingAPIError as e:
        return e.message, 400
    return resp


@doc_api.route("/<collection>/import_from_search", methods=["POST"])
def api_import_from_search(collection):
    err = _validate_import_search_request()
    if err:
        return err
    payload = request.json
    payload["dateRange"] = [x[:10] for x in payload["dateRange"]]  # format: YYYY-MM-DD

    if not (0 < payload.get("maxSize", 0) <= 500):
        return "maxSize is unspecified or out of range (1-500)", 400

    collection_api_impl.import_from_search.delay(
        collection=collection,
        q=payload["query"],
        media_type=payload["mediaType"],
        key=g.bing_api_key,
        region=payload["region"],
        max_docs=payload["maxSize"],
        freshness=payload["freshness"],
        news_category=payload.get("newsCategory", "Any"),
        start_date=payload.get("startDate"),
        end_date=payload.get("endDate"),
    )
    return "Job submitted", 201


@doc_api.route("/<collection>/import_from_twitter", methods=["POST"])
def api_import_from_twitter(collection):
    es_index = collection

    # Check if API key is configured
    api_key = request.headers.get("X-Twitter-API-Key")
    if api_key is None:
        api_key = Config.default_twitter_bearer_token

    # Unauthorized if no key is present
    if not api_key:
        return (
            "X-Twitter-API-Key header missing and no default key is provided in the server.",
            403,
        )

    # Assure payload is valid
    payload = request.json
    if not all(
        key in payload
        for key in ("identifiers", "type", "time", "relations", "esindex")
    ):
        return "Error: invalid payload (necessary parameter(s) missing)", 400

    data_type = payload.get("type")
    if data_type not in ("user", "tweet", "hashtag"):
        return "Error: invalid data type", 400

    identifiers = request.json.get("identifiers")
    time_frame = request.json.get("time")
    relations = request.json.get("relations")
    description = request.json.get("description")

    if time_frame not in ("week", "month", "3month"):
        return "Error: invalid time-frame", 400

    result = flask_jsonify(
        collection_api_impl.import_from_twitter(
            identifiers,
            data_type,
            time_frame,
            relations,
            es_index,
            description,
            api_key,
        )
    )
    return result, 201


@doc_api.route("/<collection>/preview", methods=["POST"])
def api_preview_query(collection):
    index = collection
    skip = request.json.get("skip", 0)
    size = request.json.get("size", 10)
    query = request.json["query"]
    es_request_body = {
        "size": size,
        "fields": ["title", "author", "content", "text"],
        "_source": False,
        "query": query,
        "from": skip,
    }
    es_resp = es_request("GET", f"/{index}/_search", json=es_request_body).json()
    if "hits" not in es_resp:
        return jsonify({"hits": [], "total": 0, "gte": False})
    resp = es_resp["hits"]
    del resp["max_score"]
    resp["gte"] = resp["total"]["relation"] == "gte"
    resp["total"] = resp["total"]["value"]
    resp["hits"] = [{"id": x["_id"], "fields": x["fields"]} for x in resp["hits"]]
    for doc in resp["hits"]:
        if "text" in doc["fields"]:
            doc["fields"]["content"] = doc["fields"]["text"]
    return flask_jsonify(resp)


@doc_api.route("/<collection>/batch", methods=["POST"])
def api_batch_submit(collection):
    index = collection
    tasks = request.json["tasks"]
    for task in tasks:
        if task not in background.name_to_celery_task:
            return f"Invalid task: {task}", 400
    query = request.json["query"]
    es_request_body = {"track_total_hits": True, "_source": False, "query": query}
    es_resp = es_request("GET", f"/{index}/_search", json=es_request_body).json()
    num_docs = es_resp["hits"]["total"]["value"]
    current_app.logger.info("[batch job] total documents %s", num_docs)

    batch_id = "".join(
        random.choice("ABCDEFGHJKLMIPQRSTUVWXYZ0123456789") for _ in range(9)
    )
    batch_memo = request.json.get("memo", "Unnamed")
    chains = background.get_task_chains(tasks)

    batch_tasks = []
    for doc in es_resp["hits"]["hits"]:
        doc_id = doc["_id"]
        doc_chains = []
        for chain in chains:
            sigs = [
                Signature(
                    task=background.name_to_celery_task[task],
                    args=(
                        g.collection,
                        doc_id,
                    ),
                    options={"ignore_result": True},
                    immutable=True,
                )
                for task in chain
            ]
            doc_chains.append(celery_chain(*sigs))
        batch_tasks.append(celery_group(*doc_chains, ignore_result=True))
    # start the whole batch
    celery_group(*batch_tasks, ignore_result=True).apply_async(ignore_result=True)
    return flask_jsonify(
        {
            "num_docs": num_docs,
            "num_tasks": len(tasks) * num_docs,
            "batch_id": batch_id,
            "memo": batch_memo,
        }
    )


def handle_internal_error(e):
    if isinstance(e, RequestError):
        return e.message, 401
    return (
        "Internal server error. Please contact administrators if the error persists.",
        500,
    )


if __name__ == "__main__":
    app = create_app()
    print(app.url_map)
    app.run(port=14141)
