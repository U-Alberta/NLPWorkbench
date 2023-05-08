"""
Firing background tasks, like precomputing model outputs.
"""

# OPTIMIZE: set priority to 0 for all calls here

import logging
import re
import os

assert os.environ["RPC_CALLER"] == "1"

from flask import g
import networkx as nx
from celery import group
from celery.result import allow_join_result

from .ner import resolve_coreferences, run_ner
from .linker import follow_coreference, run_linker
from .semantic import run_amr_parsing, extract_person_relations_from_amr_content
from .vader import run_vader
from .relation_extraction import run_batch as run_re
from .utils import es_request, es_writeback, dictify
from .config import Config
from .rpc import create_celery

celery = create_celery("workbench.background")


def fix_es_news(news):
    # url is sometimes concatenated with content
    # if so, we need to split it
    parts = re.split(r"\s+", news["url"], maxsplit=1)
    if len(parts) > 1:
        news["url"] = parts[0]
        news["content"] = parts[1]
    news["source"] = "es"
    return news


def get_doc(doc_id):
    # TODO: string interpolation doesn't look safe
    r = es_request("GET", f"/{g.collection}/_doc/{doc_id}").json()
    r['_source']['id'] = doc_id
    return fix_es_news(r["_source"])


@celery.task
def precompute_ner(doc_id):
    doc = get_doc(doc_id)
    # OPTIMIZE: better use celery.chain here.
    with allow_join_result():
        ner_output = run_ner.apply_async(args=(doc["title"], doc["content"]), priority=0).get()
    ner_output = resolve_coreferences(ner_output)
    # each element must all be objects, to be abled to be stored in elasticsearch
    ner_output = [
        [{"text": x} if type(x) == str else x for x in sent] for sent in ner_output
    ]
    ner_output = dictify(ner_output)
    es_writeback(doc_id, Config.CacheKeys.ner_output, ner_output)
    return ner_output


@celery.task
def precompute_linker(doc_id):
    logging.info("precompute_linker")
    doc = get_doc(doc_id)
    paragraph = doc.get(Config.CacheKeys.ner_output)
    if paragraph is None:
        logging.info("ner output not available for doc %s, precomputing", doc_id)
        # OPTIMIZE: better use celery.chain here.
        with allow_join_result():
            paragraph = precompute_ner.delay(doc_id).get()
    unique_mentions = set()
    for sent in paragraph:
        for token in sent:
            if "text" in token:
                continue
            # is a mention
            resolved_coref = follow_coreference(paragraph, token)
            task = resolved_coref["sent_idx"], resolved_coref["token_idx"]
            if task in unique_mentions:
                continue
            unique_mentions.add(task)
    unique_mentions = list(unique_mentions)
    logging.info("Unique mentions: %s", unique_mentions)
    linker_tasks = group(*[run_linker.si(paragraph, paragraph[x[0]][x[1]]) for x in unique_mentions])
    # OPTIMIZE: better use celery.chain here.
    with allow_join_result():
        linker_outputs = linker_tasks.delay().get()
    cache_item = {}
    for mention, output in zip(unique_mentions, linker_outputs):
        cache_item[f"||arg0:{mention[0]}||arg1:{mention[1]}"] = output
    es_doc = {
        Config.CacheKeys.linker_output: cache_item,
        Config.CacheKeys.full_linker_output: True
    }
    es_writeback(doc_id, None, dictify(es_doc))


@celery.task
def precompute_amr(doc_id):
    logging.info("precompute_amr")
    doc = get_doc(doc_id)
    # OPTIMIZE: better use celery.chain here.
    with allow_join_result():
        amr_output = run_amr_parsing.delay(doc["title"], doc["content"]).get()
    es_writeback(doc_id, Config.CacheKeys.amr_output, dictify(amr_output))
    return amr_output


@celery.task
def precompute_person_rel(doc_id):
    logging.info("precompute_person_rel")
    doc = get_doc(doc_id)
    amr_output = doc.get(Config.CacheKeys.amr_output)
    if amr_output is None:
        logging.info("amr output not available for doc %s, precomputing", doc_id)
        # OPTIMIZE: better use celery.chain here.
        with allow_join_result():
            amr_output = precompute_amr.delay(doc_id).get()
    # OPTIMIZE: better use celery.chain here.
    with allow_join_result():
        outputs = extract_person_relations_from_amr_content(amr_output)
    relations = [{"sent": x[0], "rel_text": x[1]} for x in outputs]  # ignore subgraphs
    es_writeback(doc_id, Config.CacheKeys.person_rel_output, dictify(relations))


@celery.task
def precompute_vader(doc_id):
    logging.info("precompute_vader")
    doc = get_doc(doc_id)
    # OPTIMIZE: better use celery.chain here.
    with allow_join_result():
        vader_output = run_vader.delay(doc["content"]).get()
    es_writeback(doc_id, Config.CacheKeys.vader_output, dictify(vader_output))
    return vader_output

@celery.task
def precompute_re(doc_id):
    logging.info("precompute_re")
    doc = get_doc(doc_id)
    # OPTIMIZE: better use celery.chain here.
    with allow_join_result():
        # TODO: test this
        re_output = run_re.apply_async(args=([doc["title"] + "\n" + doc["content"]], ), priority=0).get()
    es_writeback(doc_id, Config.CacheKeys.re_output, dictify(re_output))
    return re_output


def get_task_chains(required_tasks):
    ancestors = set()
    required_tasks = set(required_tasks)
    for task in required_tasks:
        ancestors.add(task)
        ancestors.update(nx.ancestors(full_dep_graph, task))
    subg = full_dep_graph.subgraph(ancestors)
    chains = []
    for component_nodes in nx.weakly_connected_components(subg):
        component = subg.subgraph(component_nodes)
        chain = [x for x in nx.topological_sort(component) if x in required_tasks]
        chains.append(chain)
    logging.info("Task chains: %s", chains)
    return chains


name_to_celery_task = {
    "ner": precompute_ner,
    "linker": precompute_linker,
    "amr": precompute_amr,
    "person_rel": precompute_person_rel,
    "sentiment": precompute_vader,
    "relation": precompute_re
}


parent_tasks = {
    "linker": ["ner"],
    "person_rel": ["amr"]
}


full_dep_graph = nx.DiGraph()
for task in name_to_celery_task:
    full_dep_graph.add_node(task)
for task, deps in parent_tasks.items():
    for dep in deps:
        full_dep_graph.add_edge(dep, task)

if __name__ == '__main__':
    celery.start(argv=["-A", "workbench.background", "worker", "-l", "INFO", "--concurrency=5", "-Q", "background", "-n", "background-worker@%n"])