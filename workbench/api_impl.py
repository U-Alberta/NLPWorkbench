"""
Implementations of APIs
"""

from functools import lru_cache
import random
import base64
import re
import logging

from flask import g
from newspaper import Article

from .config import Config
from .ner import resolve_coreferences, run_ner
from .linker import run_linker
from .semantic import (
    parse_amr_output_file_content,
    extract_person_relations_from_amr_content,
    run_amr_parsing,
)
from .vader import run_vader
from .utils import es_request, es_cache
from .relation_extraction import run_batch as run_re
from .bing_search import search_news, search_webpage
from .snc import run_snc, create_index_snc, delete_index_snc, import_from_json, get_index_log


def fix_es_news(news):
    # ingestion API uses `text` as the main field
    if 'content' not in news:
        news['content'] = news['text']

    # url is sometimes concatenated with content
    # if so, we need to split it
    parts = re.split(r"\s+", news["url"], maxsplit=1)
    if len(parts) > 1:
        news["url"] = parts[0]
        news["content"] = parts[1]
    news["source"] = "es"
    return news


def get_doc(doc_id):
    if doc_id.startswith("WEB-"):
        url = base64.urlsafe_b64decode(doc_id[4:]).decode()
        return import_article(url)
    r = es_request("GET", f"/{g.collection}/_doc/{doc_id}").json()
    if "found" in r and "_source" in r:
        r["_source"]["id"] = doc_id
        return fix_es_news(r["_source"])
    return None


def list_collections(detailed: bool = False):
    es_resp = es_request("GET", "/_all").json()
    stats_resp = es_request("GET", "/_all/_stats/docs").json()
    collections = []
    for name, value in es_resp.items():
        if value["mappings"].get("_meta", {}).get("class") == "log":
            continue
        stats = stats_resp["indices"][name]
        collections.append({
            "name": name,
            "description": value["mappings"].get("_meta", {}).get("description", ""),
            "creation_date": value["settings"]["index"]["creation_date"],
            "docs": stats["total"]["docs"]["count"] - stats["total"]["docs"]["deleted"]
        })
    if detailed:
        return collections
    else:
        return [x["name"] for x in collections]


@lru_cache(maxsize=128)
def import_news(url):
    article = Article(url)
    article.download()
    article.parse()
    return {
        "id": "WEB-" + base64.urlsafe_b64encode(url.encode()).decode(),
        "title": article.title,
        "content": article.text,
        "url": url,
        "author": "; ".join(article.authors),
        "published": article.publish_date,
        "source": "web",
    }


@es_cache(key=Config.CacheKeys.ner_output)
def get_ner():
    news = g.doc
    ner_output = run_ner.delay(news["title"], news["content"]).get()
    ner_output = resolve_coreferences(ner_output)
    # each element must all be objects, to be abled to be stored in elasticsearch
    ner_output = [
        [{"text": x} if type(x) == str else x for x in sent] for sent in ner_output
    ]
    return ner_output


@es_cache(key=Config.CacheKeys.linker_output)
def get_linker_output(sent_idx, mention_idx):
    paragraph = get_ner()
    mention = paragraph[sent_idx][mention_idx]
    candidates = run_linker.delay(paragraph, mention).get()
    return candidates


def get_random_article():
    query = {
        "size": 1,
        "query": {
            "function_score": {
                "random_score": {"seed": random.randrange(2147483648), "field": "id"}
            }
        },
    }
    r = es_request("GET", f"/{g.collection}/_search", json=query).json()
    logging.info(r)
    if "hits" not in r:
        return None
    return fix_es_news(r["hits"]["hits"][0]["_source"])


@lru_cache(maxsize=128)
def import_article(url):
    article = Article(url)
    article.download()
    article.parse()
    return {
        "id": "WEB-" + base64.urlsafe_b64encode(url.encode()).decode(),
        "title": article.title,
        "content": article.text,
        "url": url,
        "author": "; ".join(article.authors),
        "published": article.publish_date,
        "source": "web",
    }


@es_cache(key=Config.CacheKeys.amr_output)
def parse_or_read_cached_amr():
    news = g.doc
    amr_output_content = run_amr_parsing.delay(news["title"], news["content"]).get()
    return amr_output_content


def semantic_parse_news():
    amr_output_content = parse_or_read_cached_amr()
    output = parse_amr_output_file_content(
        amr_output_content, should_simplify_graph=True
    )
    output = [
        {"sentence": sent, "nodes": graph.nodes, "edges": graph.edges}
        for sent, graph in output
    ]
    return output


@es_cache(key=Config.CacheKeys.person_rel_output)
def extract_person_relations():
    amr_output_content = parse_or_read_cached_amr()
    outputs = extract_person_relations_from_amr_content(amr_output_content)

    relations = [{"sent": x[0], "rel_text": x[1]} for x in outputs]  # ignore subgraphs
    return relations


@es_cache(key=Config.CacheKeys.vader_output)
def analyze_sentiment():
    news = g.doc
    return run_vader.delay(news["content"]).get()


@es_cache(key=Config.CacheKeys.re_output)
def extract_relations():
    news = g.doc
    #re_celery = create_celery("api_impl", "relation")
    texts = [news["title"] + "\n" + news["content"]]
    output = run_re.delay(texts).get()
    for fact in output:
        fact["sents"] = list(set(fact["sents"]))
    return output


def build_sn(identifiers, data_type, time_frame, relations, es_index, description):
    # located at snc/snc.py
    # TODO: change this to async call
    status = run_snc.delay(identifiers, data_type, time_frame, relations, es_index, description).get()
    return status


def call_index_snc(es_index_name, description):
    status = create_index_snc.delay(es_index_name, description).get()
    return status


def call_delete_index_snc(es_index_name):
    status = delete_index_snc.delay(es_index_name).get()
    return status


def call_upload_localfile_snc(es_index_name, description, file_content):
    status = import_from_json.delay(es_index_name = es_index_name, file_content = file_content, description = description).get()
    return status


@lru_cache(maxsize=128)
def preview_bing_news_search(q, mkt, category, freshness):
    results = search_news(q, mkt, category, freshness)
    for doc in results["docs"]:
        # make sure they have the same format as webpage search
        doc["snippet"] = doc["description"]
    results["mediaType"] = "news"
    return results


@lru_cache(maxsize=128)
def preview_bing_webpage_search(q, mkt, freshness, start_date, end_date):
    results = search_webpage(q, mkt, freshness, start_date=start_date, end_date=end_date)
    results["mediaType"] = "webpage"
    return results


def call_get_index_log(es_index_name):
    status = get_index_log.delay(es_index_name).get()
    return status
