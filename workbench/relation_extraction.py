from tempfile import TemporaryDirectory
import json
from dataclasses import dataclass

from .rpc import create_celery
from .utils import dynamic_import, Models
from .config import Config


celery = create_celery("workbench.relation_extraction", "relation_extraction")


@dataclass
class Relation:
    subject: str
    object: str
    predicate: str
    sents: str


def _parse_raw_rel_output(sentences, rel_output):
    # convert to typed paragraph
    n = 0
    relations = []
    for sent_idx in range(len(sentences)):
        tokens = sentences[sent_idx]
        sent_rel = rel_output[sent_idx]
        sent = " ".join(tokens)
        for i in range(len(sent_rel)):
            for j in range(4):  # first 4 elements are token indices
                sent_rel[i][j] -= n
            # convert absolute index to relative index
        for subj_start, subj_end, obj_start, obj_end, rel_type in sent_rel:
            subj = " ".join(tokens[subj_start : subj_end + 1])
            obj = " ".join(tokens[obj_start : obj_end + 1])
            relations.append(Relation(subj, obj, rel_type, [sent]))
        n += len(sentences[sent_idx])
    return relations


@celery.task
def run_rel(sentences, predicted_ner):
    external_run_rel = dynamic_import(Config.rel_script, Config.rel_script_entrypoint)

    with TemporaryDirectory() as pure_re_dir:
        input_file = {
            "sentences": sentences,
            "doc_key": "placeholder",
            "predicted_ner": predicted_ner,
        }
        input_file["ner"] = [[] for _ in predicted_ner]
        input_file["relations"] = [[] for _ in predicted_ner]
        with open(f"{pure_re_dir}/ent_pred_test.json", "w") as f:
            json.dump(input_file, f)

        # run pure re
        cmd_args = [
            "--do_eval",
            "--eval_test",
            "--model",
            Config.rel_model,
            "--context_window",
            "100",
            "--task",
            "ace05",
            "--entity_output_dir",
            pure_re_dir,
            "--output_dir",
            pure_re_dir,
        ]
        external_run_rel(cmd_args, Models)

        # read output
        with open(f"{pure_re_dir}/predictions.json") as f:
            rel_output = json.load(f)["predicted_relations"]

        relations = _parse_raw_rel_output(sentences, rel_output)
        return relations


if __name__ == "__main__":
    # must import torch before celery starts, otherwise torch.cuda.is_available() will always be False
    import torch

    print("cuda available?", torch.cuda.is_available())

    celery.start(
        argv=[
            "-A",
            "workbench.relation_extraction",
            "worker",
            "-l",
            "INFO",
            "--concurrency=1",
            "-Q",
            "relation_extraction",
            "-P",
            "solo",
            "-n",
            "rel-worker@%n",
        ]
    )
