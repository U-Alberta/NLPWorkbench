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
import logging

from celery import chain as celery_chain, group as celery_group, Signature
from flask import Flask, Blueprint, jsonify as flask_jsonify, request, g
from flask_cors import CORS
from neo4j import GraphDatabase

from config import Config
import background
from utils import es_request, dictify
import api_impl
from rpc import create_celery


neo4j = GraphDatabase.driver(Config.neo4j_url, auth=Config.neo4j_auth)
doc_api = Blueprint("doc_api", __name__)
app = Flask(__name__)

def create_app():
    app.register_blueprint(doc_api)
    CORS(app)
    return app


def jsonify(obj):
    return flask_jsonify(dictify(obj))


@doc_api.before_request
def verify_collection_and_load_article():
    """
    TODO: so far collection is specified in URL params.
    To be consistent with REST API, it should be in the URL path.
    """
    doc_id = None
    if request.view_args is not None:
        doc_id = request.view_args.get("doc_id")
    if doc_id is not None and not doc_id.startswith("WEB-"):
        # only verify collection for non-web articles
        # if import an article from web, collection is not specified
        collection = request.args.get("collection")
        if collection not in Config.es_article_collection_whitelist:
            return "Article Collection Invalid", 403
        g.collection = collection
    # load article
    if doc_id is None:
        return
    doc = api_impl.get_doc(doc_id)
    if doc is None:
        return "Document Not Found", 404
    g.doc = doc
    g.bypass_cache = request.args.get("bypass_cache", False) is not False


@app.route("/")
def hello():
    return "It's working!"


@doc_api.route("/news/<doc_id>")
def api_pull_article(doc_id):
    return g.doc


@doc_api.route("/news/random")
def api_random_article():
    article = api_impl.get_random_article()
    return jsonify(article)


@app.route("/news/import", methods=["POST"])
def api_import_article():
    url = request.json["url"]
    try:
        article = api_impl.import_article(url)
    except:
        return "Failed to retrieve / parse article.", 400
    return jsonify(article)


@doc_api.route("/ner/<doc_id>")
def api_run_ner(doc_id):
    ner_output = api_impl.get_ner()
    # non-entity tokens are wrapped as a dict {"text": token}
    # for compatibility with es.
    # we need to unwrap them to be used in the frontend
    ner_output = [
        [x["text"] if "text" in x else x for x in sent] for sent in ner_output
    ]
    return flask_jsonify(ner_output)


@doc_api.route("/link/<doc_id>/<int:sent_idx>/<int:mention_idx>")
def api_run_linker(doc_id, sent_idx, mention_idx):
    logging.info("api_run_linker")
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


@doc_api.route("/entity/<entity_id>/attributes")
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


@doc_api.route("/entity/<entity_id>/description")
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


@doc_api.route("/semantic/<doc_id>")
def api_semantic_parse_news(doc_id):
    return jsonify(api_impl.semantic_parse_news())


@doc_api.route("/person_relations/<doc_id>")
def api_extract_person_relations(doc_id):
    return flask_jsonify(api_impl.extract_person_relations())


@doc_api.route("/sentiment/<doc_id>")
def api_analyze_sentiment(doc_id):
    return flask_jsonify(api_impl.analyze_sentiment())


@doc_api.route("/relation/<doc_id>")
def api_relation_extraction(doc_id):
    return flask_jsonify(api_impl.extract_relations())

@app.route("/snc/run", methods=["POST"])
def api_snc_run():
    data_type = request.json.get("type")
    if data_type not in ("users", "tweets"):
        return "Invalid type", 400
    # TODO: change `data` to more readable names like `users` and `tweets`
    data = request.json.get("data")
    if data is None or len(data) == 0:
        return "Invalid data", 400
    time_frame = request.json.get("time")
    if time_frame not in ("week", "month", "3month"):
        return "Invalid time", 400

    result = flask_jsonify(api_impl.build_sn(data, type, time_frame))
    return result, 200


@app.route("/admin/preview", methods=["POST"])
def api_preview_query():
    index = request.json["index"]
    if index not in Config.es_article_collection_whitelist:
        return "Invalid index", 400
    query = request.json["query"]
    es_request_body = {
        "size": 10,
        "fields": ["title", "author"],
        "_source": False,
        "query": query,
    }
    es_resp = es_request("GET", f"/{index}/_search", json=es_request_body).json()
    if "hits" not in es_resp:
        return jsonify({"hits": [], "total": 0})
    resp = es_resp["hits"]
    del resp["max_score"]
    if resp["total"]["relation"] == "gte":
        resp["total"] = f'≥ {resp["total"]["value"]}'
    else:
        resp["total"] = resp["total"]["value"]
    resp["hits"] = [{"id": x["_id"], "fields": x["fields"]} for x in resp["hits"]]
    return flask_jsonify(resp)


@app.route("/admin/batch", methods=["POST"])
def api_batch_submit():
    index = request.json["index"]
    if index not in Config.es_article_collection_whitelist:
        return "Invalid index", 400
    tasks = request.json["tasks"]
    for task in tasks:
        if task not in background.name_to_celery_task:
            return f"Invalid task: {task}", 400
    query = request.json["query"]
    es_request_body = {"track_total_hits": True, "_source": False, "query": query}
    es_resp = es_request("GET", f"/{index}/_search", json=es_request_body).json()
    num_docs = es_resp["hits"]["total"]["value"]
    logging.info("[batch job] total documents %s", num_docs)

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
                    args=(doc_id,),
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


@app.route("/admin/collections", methods=["GET"])
def api_available_collections():
    return flask_jsonify(Config.es_article_collection_whitelist)


@app.route("/test", methods=["GET"])
def api_test():
    celery = create_celery("api", "relation")
    sents = [
        "Cardy resigns as N.B. education minister, sends scorching letter to premier."
        "Dominic Cardy has resigned as New Brunswick's minister of education and early childhood development."
        "Cardy announced in a tweet that he was quitting the cabinet of Premier Blaine Higgs but would stay on as a Progressive Conservative MLA for Fredericton West-Hanwell.",
    ]
    #output = run_re.delay(news["title"], news["content"]).get()
    output = celery.signature("relation.run_batch", args=[sents]).delay().get()
    print(output)
    return flask_jsonify(output)


if __name__ == '__main__':
    app = create_app()
    print(app.url_map)
    app.run(port=14141)
