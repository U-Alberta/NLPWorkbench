import os
from pathlib import Path

def p(path):
    # convert relative path to absolute path
    return str(Path(__file__).parent / path)

class Config:
    embeddings_db = p("db/embeddings.sqlite3")

    neo4j_url = "bolt://neo4j:7687"
    neo4j_auth = ("neo4j", "wdmuofa")

    ner_script = p("thirdparty/pure-ner/run_ner.py")
    ner_script_entrypoint = "call"
    ner_model = p("thirdparty/ent-bert-ctx300")

    # AMR parsing
    amr_script = p("thirdparty/amrbart/fine-tune/inference_amr.py")
    amr_script_entrypoint = "call"
    amr_model = p("thirdparty/AMRBART-large-finetuned-AMR3.0-AMRParsing")
    # AMR2Text
    amr2text_script = p("thirdparty/amrbart/fine-tune/run_amr2text.py")
    amr2text_script_entrypoint = "call"
    amr2text_model = p("thirdparty/AMRBART-large-finetuned-AMR3.0-AMR2Text")

    es_url = "http://elasticsearch:9200"
    es_auth = ("elastic", "elastic")
    es_article_collection_whitelist = ("bloomberg-reuters-v1", "signal-v1", ) # DEPRECATED
    es_entity_collection = "entities"

    class CacheKeys:
        ner_output = "raw-ner-output"
        linker_output = "raw-linker-output"
        full_linker_output = "linker-output-full" # flag indicating if all mentions are linked
        amr_output = "raw-amr-output"
        person_rel_output = "raw-person-rel-output"
        vader_output = "vader-output"
        re_output = "re-output-v2"

    class RPC:
        broker = os.environ.get("RPC_BROKER", "redis://:UTLhRXzpeF5sa2QjRch5PPl2EJx1H2@redis")
        backend = os.environ.get("RPC_BACKEND", "redis://:UTLhRXzpeF5sa2QjRch5PPl2EJx1H2@redis")