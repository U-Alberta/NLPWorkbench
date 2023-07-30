"""
AMR parsing for semantic analysis
"""
from tempfile import TemporaryDirectory
import os
import re
import json
from itertools import product
from dataclasses import dataclass
from typing import *
import logging
from pathlib import Path

try:
    from lark import Lark, Tree, Transformer, LarkError
except ImportError as e:
    import os

    if os.environ.get("RPC_CALLER") is None:
        raise e

    class Transformer:
        # mock class
        pass


from .utils import asdict, dynamic_import, Models as model_manager
from .config import Config
from .ner import extract_sentences
from .rpc import create_celery


with open(Path(__file__).parent / "penman.ebnf") as f:
    _grammar = f.read()
_parser = None

amr_parsing_celery = create_celery("workbench.semantic", "amr_parsing")
amr2text_celery = create_celery("workbench.semantic", "amr2text")


@dataclass
class AMRVariable:
    name: str
    concept: str
    _edges: List["AMREdge"]

    def asdict(self):
        return {"name": self.name, "concept": self.concept}

    def __str__(self):
        return f"[{self.name} / {self.concept}]"

    def __repr__(self) -> str:
        return str(self)

    def __getitem__(self, rel) -> "AMRNode":
        for edge in self._edges:
            if edge.var1 == self and edge.relationship == rel:
                return edge.var2
        raise KeyError

    def pretty_tree(self, indent=0) -> str:
        r = ""
        r += " " * indent + str(self) + "\n"
        for edge in self.outbound_edges:
            r += " " * indent + "--> " + edge.relationship + "\n"
            r += edge.var2.pretty_tree(indent + 8)
        return r

    def get(self, rel, fallback=None) -> Optional["AMRNode"]:
        try:
            return self[rel]
        except KeyError:
            return fallback

    @property
    def outbound_edges(self) -> List["AMREdge"]:
        edges = [edge for edge in self._edges if edge.var1 == self]
        return sorted(edges, key=lambda edge: edge.relationship)

    def add_edge(self, var2, relationship):
        self._edges.append(AMREdge(self, var2, relationship))

    def to_spring(self, delim="\u0120", lit_begin="<lit>", lit_end="</lit>") -> str:
        s = f"{delim}( {delim}<pointer:{self.name[1:]}> {delim}{self.concept} "
        for edge in self.outbound_edges:
            s += f"{delim}:{edge.relationship} {edge.var2.to_spring(delim, lit_begin, lit_end)} "
        s += f"{delim})"
        return s


@dataclass
class AMRConstant:
    value: Union[int, str, float]
    name: str = None
    literal: bool = False

    def asdict(self):
        return asdict(self)

    def __str__(self):
        return str(self.value)

    def __repr__(self) -> str:
        return str(self)

    def pretty_tree(self, indent=0) -> str:
        return " " * indent + str(self) + "\n"

    def to_spring(self, delim="\u0120", lit_begin="<lit> ", lit_end=" </lit>") -> str:
        if self.literal:
            return f"{delim}{lit_begin}{self.value}{lit_end}{delim}"
        else:
            return f"{delim}{self.value} "


@dataclass
class AMRRef:
    name: str

    def to_spring(self, delim="\u0120", lit_begin=None, lit_end=None) -> str:
        return f"{delim}<pointer:{self.name[1:]}>"


AMRNode = Union[AMRVariable, AMRConstant, AMRRef]


@dataclass
class AMREdge:
    var1: AMRNode
    var2: AMRNode
    relationship: str

    def asdict(self):
        return {
            "var1": self.var1.name,
            "var2": self.var2.name,
            "relationship": self.relationship,
        }

    def __str__(self):
        return f"{self.var1} - {self.relationship} -> {self.var2}"

    def __repr__(self) -> str:
        return str(self)


@dataclass
class AMRGraph:
    nodes: List[AMRVariable]
    edges: List[AMREdge]

    def asdict(self):
        return {
            "nodes": [node.asdict() for node in self.nodes],
            "edges": [edge.asdict() for edge in self.edges],
        }


@amr_parsing_celery.task
def run_amr_parsing(title, content, return_amrbart_format=False) -> str:
    import torch
    logging.info("Run amr parsing...")
    sentences, _ = extract_sentences(title, content)
    sentences = [" ".join(sent) for sent in sentences]
    if len(sentences) == 0:
        return ""
    with TemporaryDirectory() as amr_input_dir, TemporaryDirectory() as amr_output_dir:
        logging.info("amr ourput dir: %s", amr_output_dir)
        with open(f"{amr_input_dir}/test.jsonl", "w") as amr_input_file:
            for sent in sentences:
                amr_input_file.write(json.dumps({"sent": sent, "amr": ""}) + "\n")

        env = os.environ
        env["OMP_NUM_THREADS"] = "16"
        # run amrbart
        cmd_args = {
            "data_dir": amr_input_dir,
            "task": "text2amr",
            "test_file": amr_input_dir + "/test.jsonl",
            "output_dir": amr_output_dir,
            "data_cache_dir": "/tmp",
            "overwrite_cache": True,
            "model_name_or_path": Config.amr_model,
            "overwrite_output_dir": "",
            "unified_input": True,
            "per_device_eval_batch_size": 4,
            "max_source_length": 300,
            "max_target_length": 768,
            "val_max_target_length": 768,
            "generation_max_length": 768,
            "generation_num_beams": 5,
            "predict_with_generate": "",
            "smart_init": False,
            "use_fast_tokenizer": False,
            "logging_dir": "/tmp",
            "seed": 42,
            "dataloader_num_workers": 4,
            "eval_dataloader_num_workers": 4,
            "do_predict": "",
            "include_inputs_for_metrics": "",
            "ddp_find_unused_parameters": False,
            "report_to": "tensorboard",
            "dataloader_pin_memory": True,
        }

        if torch.cuda.is_available():  # use fp16 if gpu is available
            cmd_args["fp16"] = ""
            cmd_args["fp16_backend"] = "auto"
            cmd_args["fp16_full_eval"] = ""

        cmd_args_array = []
        for k, v in cmd_args.items():
            cmd_args_array.append(f"--{k}")
            if v != "":
                cmd_args_array.append(str(v))
        print(cmd_args_array)
        call_amrbart = dynamic_import(Config.amr_script, Config.amr_script_entrypoint)
        call_amrbart(cmd_args_array, model_manager)

        with open(f"{amr_output_dir}/generated_predictions.txt") as f:
            raw_output = f.readlines()
        assert len(raw_output) == len(sentences)

        if not return_amrbart_format:
            output_lines = []
            for sent, amr in zip(sentences, raw_output):
                sent = sent.replace("\n", " ")
                amr = amr.replace("</AMR>", "")
                amr = convert_amrbart_v2_output(amr)
                output_lines.append(f"# ::snt {sent}")
                output_lines.append(amr)
                output_lines.append("")
            return "\n".join(output_lines)
        else:
            amrbart_output = []
            for sent, amr in zip(sentences, raw_output):
                sent = sent.replace("\n", " ")
                amr = amr.replace("</AMR>", "")
                amrbart_output.append({"sent": sent, "amr": amr})
            return amrbart_output


@amr2text_celery.task
def run_amr_to_text(roots: List[AMRNode], amrbart_input: List = None) -> List[str]:
    """
    Each amr graph must be a rooted tree.
    Pass in the root nodes.
    """
    import torch
    if amrbart_input is None:
        amrbart_input = []
    if len(roots) + len(amrbart_input) == 0:
        return []
    with TemporaryDirectory() as amr_input_dir, TemporaryDirectory() as amr_output_dir:
        with open(f"{amr_input_dir}/test.jsonl", "w") as amr_input_file:
            for root in roots:
                amr_string = root.to_spring(delim=" ", lit_begin='"', lit_end='"')
                amr_input_file.write(json.dumps({"sent": "", "amr": amr_string}))
                amr_input_file.write("\n")
            for amr in amrbart_input:
                amr_input_file.write(json.dumps(amr))
                amr_input_file.write("\n")

        env = os.environ
        env["OMP_NUM_THREADS"] = "8"
        # run amrbart
        cmd_args = {
            "data_dir": amr_input_dir,
            "task": "amr2text",
            "test_file": amr_input_dir + "/test.jsonl",
            "output_dir": amr_output_dir,
            "data_cache_dir": "/tmp",
            "overwrite_cache": True,
            "overwrite_output_dir": "",
            "model_name_or_path": Config.amr2text_model,
            "unified_input": True,
            "per_device_eval_batch_size": 4,
            "max_source_length": 768,
            "max_target_length": 300,
            "val_max_target_length": 300,
            "generation_max_length": 300,
            "generation_num_beams": 5,
            "predict_with_generate": "",
            "smart_init": False,
            "use_fast_tokenizer": False,
            "logging_dir": "/tmp",
            "seed": 42,
            "dataloader_num_workers": 4,
            "eval_dataloader_num_workers": 2,
            "do_predict": "",
            "include_inputs_for_metrics": "",
            "ddp_find_unused_parameters": False,
            "report_to": "tensorboard",
            "dataloader_pin_memory": True,
        }
        if torch.cuda.is_available():  # use fp16 if gpu is available
            cmd_args["fp16"] = ""
            cmd_args["fp16_backend"] = "auto"
            cmd_args["fp16_full_eval"] = ""

        cmd_args_array = []
        for k, v in cmd_args.items():
            cmd_args_array.append(f"--{k}")
            if v != "":
                cmd_args_array.append(str(v))
        print(cmd_args_array)
        call_amrbart = dynamic_import(
            Config.amr2text_script, Config.amr2text_script_entrypoint
        )
        call_amrbart(cmd_args_array, model_manager)

        with open(f"{amr_output_dir}/generated_predictions.txt") as f:
            return f.readlines()


def parse_amr_output_file_content(
    content, should_simplify_graph=False, **kwargs
) -> List[Tuple[str, AMRGraph]]:
    global _parser
    if _parser is None:
        _parser = Lark(_grammar, start="amr_tree")

    lines = content.split("\n")
    lines.append("")
    outputs = []

    sent = None
    amr_output_lines = []
    for line in lines:
        if line.startswith("# ::snt "):
            sent = line[8:].strip()
        elif line.startswith("#"):
            continue
        elif not line.strip():
            if len(amr_output_lines) > 0:
                amr_output = " ".join(amr_output_lines)
                try:
                    tree = _parser.parse(amr_output)
                except LarkError:
                    logging.warning(f"Failed to parse AMR: {amr_output}")
                    continue
                graph = amr_tree_to_graph(tree, **kwargs)
                outputs.append((sent, graph))
                print(sent)
                amr_output_lines = []
        else:
            amr_output_lines.append(line)
    return outputs


def parse_amr_output_file(filename, **kwargs):
    with open(filename) as f:
        return parse_amr_output_file_content(f.read(), **kwargs)


def convert_amrbart_v2_output(v2_output):
    output = v2_output
    # try to fix mismatched brackets
    if output.count("(") != output.count(")"):
        tokens = []
        for line in output.splitlines():
            tokens.extend(line.strip().split())
            tokens.append('\n')
        tokens.pop()
        open_paren = 0
        tracking = True
        for i, token in enumerate(tokens):
            if token == '\n':
                continue
            print(f"tok {token}", open_paren, tracking)
            if token == '<lit>':
                tracking = False
            elif token == '</lit>':
                tracking = True
            if not tracking:
                continue
            if token == '(':
                open_paren += 1
            elif token == ')':
                if open_paren == 0:
                    tokens[i] = ''
                else:
                    open_paren -= 1
        output = " ".join(tokens)
    # convert <pointer:N> to zN
    output = re.sub(r"<pointer:(\d+)>", r"z\1 /", output, flags=re.MULTILINE)
    # convert zN / ) to zN) (if zN is a reference and is the last argument)
    output = re.sub(r"z(\d+) / \)", r"z\1 )", output, flags=re.MULTILINE)
    # convert zN / : to zN : (if zN is a reference and is not the last argument)
    output = re.sub(r"z(\d+) / :", r"z\1 :", output, flags=re.MULTILINE)
    # convert <lit> and </lit> to "
    output = re.sub(r"<lit> ", r'"', output, flags=re.MULTILINE)
    output = re.sub(r" </lit>", r'"', output, flags=re.MULTILINE)

    return output


class ParseToAMRTreeTransformer(Transformer):
    def attr(self, children):
        relation = children[0].value
        var2 = children[1]
        edge = AMREdge(None, var2, relation)
        return edge

    def arg(self, children):
        return self.attr(children)

    def literal(self, value):
        assert len(value) > 0
        value = value[0].value
        is_literal = False
        if value[0] == '"':
            value = value[1:-1]
            is_literal = True
        elif value in ("+", "-", "imperative", "expressive"):
            pass
        else:
            for transforms in (int, float):
                try:
                    value = transforms(value)
                    break
                except ValueError:
                    pass
        return AMRConstant(value, None, is_literal)

    def var_ref(self, children):
        return AMRRef(children[0].value)

    def var_def(self, children):
        name = children[0].value
        concept = children[1].value
        edges = children[2:]
        node = AMRVariable(name, concept, edges)
        for e in node._edges:
            e.var1 = node
        return node


def amr_tree_to_graph(tree: "Tree", add_inv_edges_to_nodes=False) -> AMRGraph:
    """
    Convert AMR tree to graph
    1. resolve variable references
    2. invert edges if relation ends with "-of"
    """
    amr_tree = ParseToAMRTreeTransformer().transform(tree)
    nodes = []
    node_map = {}
    edges = []
    inv_edges = []
    constant_cnt = 0

    def collect_nodes(node: AMRNode):
        nonlocal constant_cnt
        if isinstance(node, AMRConstant):
            node.name = f"c{constant_cnt}"
            constant_cnt += 1
            nodes.append(node)
        if isinstance(node, AMRVariable):
            nodes.append(node)
            node_map[node.name] = node
            for e in node._edges:
                collect_nodes(e.var2)

    def collect_edges(node: AMRNode):
        if isinstance(node, AMRVariable):
            for e in node._edges:
                collect_edges(e.var2)
                if isinstance(e.var2, AMRRef):  # resolve reference
                    e.var2 = node_map[e.var2.name]
                if (
                    e.relationship.endswith("-of") and e.relationship != "consist-of"
                ):  # inverse relationship
                    e.relationship = e.relationship[:-3]
                    e.var1, e.var2 = e.var2, e.var1
                    if add_inv_edges_to_nodes:
                        inv_edges.append(e)
                edges.append(e)

    collect_nodes(amr_tree)
    collect_edges(amr_tree)
    for e in inv_edges:  # if add_inv_edges_to_nodes
        for e in inv_edges:
            e.var1._edges.append(e)
    return AMRGraph(nodes, edges)


def simplify_graph(graph: AMRGraph):
    new_name_nodes = {}
    nodes_to_remove = set()
    edges = []
    for edge in graph.edges:
        if edge.relationship == "wiki":
            nodes_to_remove.add(edge.var2.name)
            # remove wiki edges
            continue
        elif edge.var1.name in new_name_nodes:
            # already
            continue
        elif isinstance(edge.var1, AMRVariable) and edge.var1.concept == "name":
            name_node = edge.var1
            # combine names
            parts = []
            i = 1  # this part is O(n^2) but I assume n is small enough
            while True:
                try:
                    op_edge = next(
                        x for x in edge.var1._edges if x.relationship == f"op{i}"
                    )
                    parts.append(str(op_edge.var2.value))
                    nodes_to_remove.add(op_edge.var2.name)
                    i += 1
                except StopIteration:
                    break
            new_node = AMRConstant(" ".join(parts), "c" + name_node.name)
            new_name_nodes[name_node.name] = new_node
        else:
            edges.append(edge)
    for edge in edges:
        if edge.var2.name in new_name_nodes:
            edge.var2 = new_name_nodes[edge.var2.name]
    graph.edges = edges
    graph.nodes = [
        x
        for x in graph.nodes
        if x.name not in new_name_nodes and x.name not in nodes_to_remove
    ] + list(new_name_nodes.values())
    return graph


def extract_person_relations(graph: AMRGraph) -> List[AMRVariable]:
    person_nodes = [
        x for x in graph.nodes if type(x) == AMRVariable and x.concept == "person"
    ]
    person_nodes = [x for x in person_nodes if x.get("name") is not None]
    relations: List[AMRVariable] = []

    def clone_subtree(root: AMRNode, is_top: bool = False) -> List[AMRNode]:
        if type(root) == AMRConstant:
            return [AMRConstant(root.value, root.name)]
        root: AMRVariable
        if root.concept == "and":
            if is_top:
                # find its parent
                parents = [x.var1 for x in graph.edges if x.var2 == root]
                return [
                    node for x in parents for node in clone_subtree(x, is_root=True)
                ]
            else:
                # bypass and
                return [
                    node
                    for x in root.outbound_edges
                    if x.relationship.startswith("op")
                    for node in clone_subtree(x.var2)
                ]

        is_entity = re.match(r".*-\d\d", root.concept) is not None
        attributes_to_keep = ("name", "location", "time", "polarity", "topic")
        new_root = AMRVariable(root.name, root.concept, [])
        new_edge_rels = []
        new_edge_alts = []
        for edge in root.outbound_edges:
            keep_edge = is_entity and edge.relationship in attributes_to_keep
            keep_edge |= root.concept in ("name", "date-entity")
            keep_edge |= edge.relationship in attributes_to_keep
            keep_edge |= is_top and edge.relationship.startswith("ARG")
            if keep_edge:
                new_leaves = clone_subtree(edge.var2, is_top=False)
                new_edge_rels.append(edge.relationship)
                new_edge_alts.append(new_leaves)
        new_roots = []
        for leaves in product(*new_edge_alts):
            new_root = AMRVariable(root.name, root.concept, [])
            for edge_rel, leaf in zip(new_edge_rels, leaves):
                assert type(leaf) == AMRVariable or type(leaf) == AMRConstant, leaf
                new_root.add_edge(leaf, edge_rel)
            new_roots.append(new_root)

        return new_roots

    for var in (x for x in graph.nodes if type(x) == AMRVariable):
        if any(
            x.var2 in person_nodes and x.relationship.startswith("ARG")
            for x in var.outbound_edges
        ):
            rels = clone_subtree(var, is_top=True)
            relations.extend(rels)
    return relations


def extract_person_relations_from_amr_content(amr_content):
    sents_and_graphs = parse_amr_output_file_content(
        amr_content, add_inv_edges_to_nodes=True
    )
    sents = []
    rel_graphs = []
    for sent, graph in sents_and_graphs:
        relations = extract_person_relations(graph)
        for rel in relations:
            sents.append(sent)
            rel_graphs.append(rel)
    texts = run_amr_to_text.delay(rel_graphs).get()
    return list(zip(sents, texts, rel_graphs))


if __name__ == "__main__":
    import logging
    import os
    import torch

    if torch.cuda.is_available():
        torch.cuda.set_device(torch.device("cuda:0"))

    logging.getLogger("penman.layout").setLevel("CRITICAL")

    if os.environ.get("AMRPARSING_RPC"):
        amr_parsing_celery.start(
            argv=[
                "worker",
                "-l",
                "INFO",
                "--concurrency=1",
                "-Q",
                "amr_parsing",
                "-P",
                "solo",
                "-n",
                "amr-parsing-worker@%n",
            ]
        )
    elif os.environ.get("AMR2TEXT_RPC"):
        amr2text_celery.start(
            argv=[
                "worker",
                "-l",
                "INFO",
                "--concurrency=1",
                "-Q",
                "amr2text",
                "-P",
                "solo",
                "-n",
                "amr2text-worker@%n",
            ]
        )
    else:
        raise ValueError("No RPC server specified in environment variables")
