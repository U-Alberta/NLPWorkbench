"""
Implementations of APIs
"""

from functools import lru_cache
import random
import base64

from flask import g
from newspaper import Article

from .config import Config
from .ner import resolve_coreferences, run_ner, extract_sentences, parse_raw_ner_output
from .linker import run_linker
from .semantic import (
    parse_amr_output_file_content,
    extract_person_relations_from_amr_content,
    run_amr_parsing,
)
from .vader import run_vader
from .utils import es_request, es_cache, fix_es_news
from .relation_extraction import run_rel
from .bing_search import search_news, search_webpage
from .classifier import (
    run_multiclass_crime_classifier,
    run_multiclass_one_vs_rest_crime_classifier,
    run_multilabel_transformer_based_classifier,
)


def get_doc(doc_id):
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
        try:
            stats = stats_resp["indices"][name]
            docs = stats["total"]["docs"]["count"] - stats["total"]["docs"]["deleted"]
        except KeyError:
            docs = 0  # unknown
        # skip system indicies
        if name in (Config.es_entity_collection, Config.es_log_index_name):
            continue
        collections.append(
            {
                "name": name,
                "description": value["mappings"]
                .get("_meta", {})
                .get("description", ""),
                "creation_date": value["settings"]["index"]["creation_date"],
                "docs": docs,
            }
        )
    if detailed:
        return collections
    else:
        return [x["name"] for x in collections]


def tokenize():
    document = g.doc
    if "sentences" not in g:
        g.sentences, g.pos = extract_sentences(document["title"], document["content"])


@es_cache(key=Config.CacheKeys.raw_pure_ner_output)
def _get_raw_pure_ner_output():
    tokenize()
    if len(g.sentences) == 0:
        return []
    return run_ner.delay(g.sentences).get()


@es_cache(key=Config.CacheKeys.ner_output)
def get_ner():
    ner_output = _get_raw_pure_ner_output()
    ner_output = parse_raw_ner_output(g.sentences, g.pos, ner_output)
    ner_output = resolve_coreferences(ner_output)
    # each element must all be objects, to be abled to be stored in elasticsearch
    ner_output = [
        [{"text": x} if type(x) == str else x for x in sent] for sent in ner_output
    ]
    return ner_output


@es_cache(key=Config.CacheKeys.re_output)
def extract_relations():
    ner_output = _get_raw_pure_ner_output()
    output = run_rel.delay(g.sentences, ner_output).get()
    return output


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
    if "hits" not in r or not r["hits"].get("hits"):
        return None
    return fix_es_news(r["hits"]["hits"][0]["_source"])


@lru_cache(maxsize=128)
def download_article_from_web(url):
    article = Article(url)
    article.download()
    article.parse()
    return {
        "id": "WEB-" + base64.urlsafe_b64encode(url.encode()).decode(),
        "title": article.title,
        "text": article.text,
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


def semantic_parse_document():
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


@lru_cache(maxsize=128)
def preview_bing_news_search(q, mkt, key, category, freshness):
    results = search_news(q, mkt, key, category, freshness)
    for doc in results["docs"]:
        # make sure they have the same format as webpage search
        doc["snippet"] = doc["description"]
    results["mediaType"] = "news"
    return results


@lru_cache(maxsize=128)
def preview_bing_webpage_search(q, mkt, key, freshness, start_date, end_date):
    results = search_webpage(
        q, mkt, key, freshness, start_date=start_date, end_date=end_date
    )
    results["mediaType"] = "webpage"
    return results


@es_cache(key=Config.CacheKeys.crime_classifier_output)
def run_crime_classifier():
    text = g.doc["content"].replace("\n", " ")

    return {
        "multiclass_prediction": [
            str(x) for x in run_multiclass_crime_classifier.delay([text]).get()
        ],
        "multiclass_OneVsRest_prediction": [
            str(x)
            for x in run_multiclass_one_vs_rest_crime_classifier.delay([text]).get()
        ],
        "multilabel_bert_prediction": [
            str(x)
            for x in run_multilabel_transformer_based_classifier.delay(
                text, "bert-base-uncased"
            ).get()
        ],
        #"multilabel_albert_prediction": [
        #    str(x)
        #    for x in run_multilabel_transformer_based_classifier.delay(
        #        text, "albert-base-v2"
        #    ).get()
        #],
        "multilabel_finbert_prediction": [
            str(x)
            for x in run_multilabel_transformer_based_classifier.delay(
                text, "ProsusAI-finbert"
            ).get()
        ],
        #"multilabel_gpt_prediction": [
        #    str(x)
        #    for x in run_multilabel_transformer_based_classifier.delay(
        #        text, "openai-gpt"
        #    ).get()
        #],
    }
