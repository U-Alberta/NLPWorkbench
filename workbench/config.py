import os
from pathlib import Path


def p(path):
    # convert relative path to absolute path
    return str(Path(__file__).parent / path)


class Config:
    embeddings_db = "/app/db/embeddings.sqlite3"

    neo4j_url = "bolt://neo4j:7687"
    neo4j_auth = ("neo4j", "wdmuofa")

    # PURE configuration
    ner_script = p("thirdparty/pure-ner/run_ner.py")
    ner_script_entrypoint = "call"
    ner_model = p("thirdparty/ent-bert-ctx300")
    rel_script = p("thirdparty/pure-ner/run_relation.py")
    rel_script_entrypoint = "call_from_external"
    rel_model = p("thirdparty/rel-bert-ctx100")

    # AMR parsing
    amr_script = p("thirdparty/amrbart/fine-tune/main.py")
    amr_script_entrypoint = "main"
    amr_model = p("thirdparty/AMRBART-large-finetuned-AMR3.0-AMRParsing")
    # AMR2Text
    amr2text_script = p("thirdparty/amrbart/fine-tune/main.py")
    amr2text_script_entrypoint = "main"
    amr2text_model = p("thirdparty/AMRBART-large-finetuned-AMR3.0-AMR2Text")

    # Classifiers
    crime_multiclass_model = "/app/models/final_model_SVM2.pkl"
    crime_multiclass_model_OneVsRest = "/app/models/final_model_OneVsRest2.pkl"
    crime_multilabel_model = "/app/models/multilabel.ftz"

    # Elasticsearch
    es_url = "http://elasticsearch:9200"
    es_password = os.environ.get("ELASTIC_PASSWORD", "elastic")
    es_auth = ("elastic", es_password)
    es_entity_collection = "entities"
    es_log_index_name = "system_logs______"

    # API keys
    default_twitter_bearer_token = os.environ.get("BEARER_TOKEN")
    default_bing_api_key = os.environ.get("BING_KEY")

    class CacheKeys:
        raw_pure_ner_output = "raw-pure-ner-output"
        ner_output = "ner-output"
        linker_output = "raw-linker-output"
        full_linker_output = (
            "linker-output-full"  # flag indicating if all mentions are linked
        )
        amr_output = "raw-amr-output-v2"
        person_rel_output = "raw-person-rel-output-v2"
        vader_output = "vader-output"
        re_output = "re-output-v3"
        crime_classifier_output = "crime-classifier-output-v2"

    class RPC:
        broker = os.environ.get("RPC_BROKER", "redis://redis")
        backend = os.environ.get("RPC_BACKEND", "redis://redis")
