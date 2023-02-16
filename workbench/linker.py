from typing import *
from dataclasses import dataclass
import logging

try:
    import numpy as np
    from neo4j import GraphDatabase

    from config import Config
    neo4j = GraphDatabase.driver(Config.neo4j_url, auth=Config.neo4j_auth)
except ImportError:
    logging.warning("neo4j is not installed. This is expected if calling celery tasks.")

from .ner import EntityMention
from .utils import es_request, Models, asdict
from .config import Config
from .rpc import create_celery

celery = create_celery("workbench.linker")

@dataclass
class Candidate:
    entity_id: str
    score: float
    names: List[str]

    def asdict(self):
        return asdict(self)


def sentence_to_string(sent) -> str:
    parts = []
    for token in sent:
        if "text" in token:
            parts.append(token["text"])
        elif "tokens" in token:
            parts.append(" ".join(token["tokens"]))
        else:
            raise ValueError("Unrecgonzied token type")
    return " ".join(parts)


def query_es(name: str, mention_type: str) -> List[Dict]:
    query = {
        "query": {
            "bool": {
                "must": {"match": {"name": name}},
                "filter": {"term": {"types": mention_type.lower()}},
            }
        },
        "collapse": {"field": "entity_id"},
        "fields": ["aliases", "entity_id", "types"],
        "_source": False,
    }
    r = es_request("GET", f"/{Config.es_entity_collection}/_search", json=query).json()

    return r["hits"]["hits"]


def compute_entity_embedding(entityId: str):
    logging.info("Computing entity embedding on the fly")
    with neo4j.session() as session:
        desc = ""  # can't compute entity embedding if there's no wiki abstract or description
        row = session.run(
            "MATCH (e: Entity) -[:WIKI_ABSTRACT]-> (wiki: WikiAbstract) WHERE e.entityId = $entity_id RETURN wiki.abstract AS abstract",
            entity_id=entityId,
        ).single()
        if row:
            desc = row["abstract"]
        if not desc:
            row = session.run(
                "MATCH (e: Entity) WHERE e.entityId = $entity_id RETURN e.desc AS desc",
                entity_id=entityId,
            ).single()
            if row:
                desc = row["desc"]
                if type(desc) == list:
                    desc = desc[0]
    if desc:
        logging.info("Got entity description")
        emb = Models.encode_sentence(desc)
        Models.get_embedding_db_conn().execute(
            "INSERT INTO entity_embeddings (entity, embedding) VALUES (?, ?)",
            (entityId, emb.tobytes()),
        )
        logging.info("Entity embedding stored in db")
    else:
        emb = np.zeros(768)
    return emb


def get_entity_embedding(entity_id: str) -> np.ndarray:
    emb = (
        Models.get_embedding_db_conn()
        .execute(
            "select embedding from entity_embeddings where entity = ?", (entity_id,)
        )
        .fetchone()
    )
    if emb is None:
        emb = compute_entity_embedding(entity_id)
    else:
        emb = np.frombuffer(emb[0], dtype=np.float32)
    return emb


def rerank(hits: List[Dict], embedding: np.ndarray) -> List[Dict]:
    sentence_emb_weight = 1.0
    score_weight = 3.0

    for hit in hits:
        hit_emb = get_entity_embedding(hit["fields"]["entity_id"][0])
        hit["_score"] = (
            max(np.dot(embedding, hit_emb), 0) * sentence_emb_weight
            + hit["_score"] * score_weight
        )
    hits.sort(key=lambda x: x["_score"], reverse=True)
    return hits


def follow_coreference(paragraph, mention):
    if "entity" in mention:
        # `mention` was serialized from `Coreference`
        if mention["entity"] is None:
            return None
        return follow_coreference(paragraph, mention["entity"])
    elif "text" in mention:
        raise TypeError("Input is not an entity mention.")
    # `mention` was serialized from a `EntityMention`
    if mention["resolved_entity"] is not None:
        return follow_coreference(paragraph, mention["resolved_entity"])
    return mention


@celery.task
def run_linker(paragraph, mention) -> Optional[str]:
    logging.info("run linker")
    """
    returns entity id
    """
    mention = follow_coreference(paragraph, mention)
    mention = EntityMention(**mention)

    max_length = 384
    context_window = 1
    context = sentence_to_string(paragraph[mention.sent_idx])[:max_length]
    for i in range(1, 1 + context_window):
        if len(context) > max_length:
            break
        if mention.sent_idx - i >= 0:
            new_context = sentence_to_string(paragraph[mention.sent_idx - i])
            if len(new_context) + len(context) < 500:
                context = new_context + " " + context
        if mention.sent_idx + i < len(paragraph):
            new_context = sentence_to_string(paragraph[mention.sent_idx + i])
            if len(new_context) + len(context) < 500:
                context = context + " " + new_context

    context_embedding = Models.encode_sentence(context)
    hits = query_es(mention.text, mention.type)
    hits = rerank(hits, context_embedding)
    candidates = [
        Candidate(
            hit["fields"]["entity_id"][0], hit["_score"], hit["fields"]["aliases"]
        )
        for hit in hits
    ]

    return candidates


if __name__ == "__main__":
    celery.start(argv=["-A", "workbench.linker", "worker", "-l", "INFO", "-Q", "linker", "-n", "linker-worker@%n", "-c", "4"])
