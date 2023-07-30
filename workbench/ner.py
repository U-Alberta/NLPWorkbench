import json
import logging
from tempfile import NamedTemporaryFile
from dataclasses import dataclass
from typing import *

from .rpc import create_celery
from .utils import Models, asdict, dynamic_import
from .config import Config


celery = create_celery("workbench.ner", "ner")


@dataclass
class EntityMention:
    tokens: List[str]
    sent_idx: int
    token_idx: int
    type: str
    proper: bool = True
    resolved_entity: Optional["EntityMention"] = None

    @property
    def text(self):
        return " ".join(self.tokens)

    def __str__(self):
        if self.resolved_entity or not self.proper:
            return f"Entity(text='{self.text}', type='{self.type}', resolved_entity={self.resolved_entity})"
        else:
            return f"Entity(text='{self.text}', type='{self.type}')"

    def __repr__(self):
        return str(self)

    def asdict(self):
        """
        WARNING: when a dataclass is sent over `dill`, `dataclass.asdict` will
        not work. Probably because fields in a dataclass are class attributes
        and they are not serialized. This is why we implemented our own `asdict`
        in utils.py.

        TLDR: Never use `dataclass.asdict`. Use `utils.asdict` instead.
        """
        r = asdict(self)
        if self.resolved_entity is not None:
            r["resolved_entity"] = self.resolved_entity.asdict()
        return r

    @classmethod
    def from_dict(d):
        return EntityMention(**d)


@dataclass
class Coreference:
    tokens: List[str]
    type: str
    entity: Optional[EntityMention]

    @property
    def text(self):
        return " ".join(self.tokens)

    def __str__(self):
        return (
            f"Coreference(text='{self.text}', type='{self.type}', entity={self.entity})"
        )

    def __repr__(self):
        return str(self)

    def asdict(self):
        r = asdict(self)
        if self.entity is not None:
            r["entity"] = self.entity.asdict()
        return r


Token = Union[str, EntityMention, Coreference]
Sentence = List[Token]
Paragraph = List[Sentence]


def extract_sentences(title: str, content: str) -> Tuple[List[str], List[str]]:
    paragraphs = [title]
    paragraphs.extend(content.split("\n\n"))
    paragraphs = [x for x in paragraphs if not x.startswith("-- ")]  # drop metadata
    paragraphs = [x for x in paragraphs if x.strip()]
    paragraphs = [x.replace("\n", " ") for x in paragraphs]  # drop superfluous newlines

    processed = []
    pos = []
    for paragraph in paragraphs:
        doc = Models.nlp(paragraph)
        for sent in doc.sents:
            tokens = [x.text for x in sent if x.text.strip()]
            token_pos = [x.pos_ for x in sent if x.text.strip()]
            if len(tokens) > 0:
                processed.append(tokens)
                pos.append(token_pos)

    return processed, pos


def parse_raw_ner_output(sentences, token_pos, ner_output):
    # convert to typed paragraph
    n = 0
    paragraph = []
    for sent_idx in range(len(sentences)):
        sent = []
        tokens = sentences[sent_idx]
        sent_ner = ner_output[sent_idx]
        for i in range(len(sent_ner)):
            sent_ner[i][0] -= n
            sent_ner[i][1] -= n
            # convert absolute index to relative index
        prev_entity_end = -1
        for ner_entity in sent_ner:
            start, end, type = ner_entity
            sent.extend(tokens[prev_entity_end + 1 : start])

            if all(
                token_pos[sent_idx][i] == "PRON" for i in range(start, end + 1)
            ) or all(token_pos[sent_idx][i] == "DET" for i in range(start, end + 1)):
                # coreference. needs to be resolved
                sent.append(Coreference(tokens[start : end + 1], type, None))
            else:
                proper = any(
                    token_pos[sent_idx][i] == "PROPN" for i in range(start, end + 1)
                )
                sent.append(
                    EntityMention(
                        tokens[start : end + 1], sent_idx, len(sent), type, proper
                    )
                )
            prev_entity_end = end
        if not sent_ner:
            sent.extend(tokens)
        else:
            sent.extend(tokens[sent_ner[-1][1] + 1 :])
        paragraph.append(sent)
        n += len(sentences[sent_idx])

    return paragraph


@celery.task
def run_ner(sentences) -> Paragraph:
    external_run_ner = dynamic_import(Config.ner_script, Config.ner_script_entrypoint)

    with NamedTemporaryFile("w") as pure_input_file, NamedTemporaryFile(
        "r"
    ) as pure_output_file:
        json.dump({"sentences": sentences, "doc_key": "placeholder"}, pure_input_file)
        pure_input_file.flush()

        # run pure
        cmd_args = [
            "--model",
            "bert-base-uncased",
            "--model_dir",
            Config.ner_model,
            "--output_dir",
            "/tmp",
            "--context_window",
            "300",
            "--test_data",
            pure_input_file.name,
            "--test_pred_filename",
            pure_output_file.name,
        ]
        external_run_ner(cmd_args, Models)

        # read output
        ner_output = json.load(pure_output_file)["predicted_ner"]
        return ner_output


def is_subseq(a, b):
    return all(x in iter(b) for x in a)


def resolve_coreferences(paragraph: Paragraph) -> Paragraph:
    encountered_entities: List[EntityMention] = []
    for sent in paragraph:
        for mention in sent:
            # type got lost in serialization
            if type(mention).__name__ == "EntityMention":
                mention: EntityMention
                if not mention.proper:
                    for entity in reversed(encountered_entities):
                        if entity.type == mention.type:
                            if entity.resolved_entity:
                                mention.resolved_entity = entity.resolved_entity
                            else:
                                mention.resolved_entity = entity
                            break
                elif mention.type == "PER":
                    for entity in reversed(encountered_entities):
                        if entity.type == "PER" and is_subseq(
                            mention.tokens, entity.tokens
                        ):
                            if entity.resolved_entity:
                                mention.resolved_entity = entity.resolved_entity
                            else:
                                mention.resolved_entity = entity
                            break
                encountered_entities.append(mention)
            elif type(mention).__name__ == "Coreference":
                mention: Coreference
                # recency
                for entity in reversed(encountered_entities):
                    if entity.type == mention.type:
                        if entity.resolved_entity:
                            mention.entity = entity.resolved_entity
                        else:
                            mention.entity = entity
                        break
    return paragraph


if __name__ == "__main__":
    # must import torch before celery starts, otherwise torch.cuda.is_available() will always be False
    import torch

    print("cuda available?", torch.cuda.is_available())

    celery.start(
        argv=[
            "-A",
            "workbench.ner",
            "worker",
            "-l",
            "INFO",
            "--concurrency=1",
            "-Q",
            "ner",
            "-P",
            "solo",
            "-n",
            "ner-worker@%n",
        ]
    )
