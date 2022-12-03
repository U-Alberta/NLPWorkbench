"""
AMR parsing for semantic analysis
"""
from tempfile import TemporaryDirectory
import os
import re
import json
from itertools import product
from dataclasses import dataclass, is_dataclass
from typing import *
import logging

try:
    from lark import Lark, Tree, Transformer
except ImportError:
    class Transformer:
        # mock class
        pass
    logging.warning("lark is not installed. This is expected if calling celery tasks.")

from utils import asdict, dynamic_import, Models as model_manager
from config import Config
from ner import extract_sentences
from rpc import create_celery

amr_parsing_celery = create_celery("semantic", "amr_parsing")
amr2text_celery = create_celery("semantic", "amr2text")


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

    def to_spring(self) -> str:
        s = f"\u0120( \u0120<pointer:{self.name[1:]}> \u0120{self.concept} "
        for edge in self.outbound_edges:
            s += f"\u0120:{edge.relationship} {edge.var2.to_spring()} "
        s += "\u0120)"
        return s


@dataclass
class AMRConstant:
    value: Union[int, str, float]
    name: str = None

    def asdict(self):
        return asdict(self)

    def __str__(self):
        return str(self.value)

    def __repr__(self) -> str:
        return str(self)

    def pretty_tree(self, indent=0) -> str:
        return " " * indent + str(self) + "\n"

    def to_spring(self) -> str:
        if type(self.value) == int or type(self.value) == float:
            return f"\u0120{self.value}"
        else:
            return f"\u0120<lit> \u0120{self.value} \u0120</lit>"


@dataclass
class AMRRef:
    name: str


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
def run_amr_parsing(title, content) -> str:
    logging.info("Run amr parsing...")
    sentences, _ = extract_sentences(title, content)
    with TemporaryDirectory() as amr_input_dir, TemporaryDirectory() as amr_output_dir:
        logging.info("amr ourput dir: %s", amr_output_dir)
        with open(f"{amr_input_dir}/test.jsonl", "w") as amr_input_file:
            for sent in sentences:
                amr_input_file.write(
                    json.dumps({"src": " ".join(sent), "tgt": ""}) + "\n"
                )
        with open(f"{amr_input_dir}/train.jsonl", "w") as amr_input_file:
            amr_input_file.write(json.dumps({"src": "", "tgt": ""}) + "\n")
        with open(f"{amr_input_dir}/val.jsonl", "w") as amr_input_file:
            amr_input_file.write(json.dumps({"src": "", "tgt": ""}) + "\n")

        env = os.environ
        env["CUDA_VISIBLE_DEVICES"] = ""  # disable GPU
        env["OMP_NUM_THREADS"] = "3"
        # run amrbart
        cmd_args = [
            "--data_dir", amr_input_dir,
            "--train_data_file", amr_input_dir + "/train.jsonl",
            "--eval_data_file", amr_input_dir + "/val.jsonl",
            "--test_data_file", amr_input_dir + "/test.jsonl",
            "--model_type", Config.amr_model,
            "--model_name_or_path", Config.amr_model,
            "--tokenizer_name_or_path", "facebook/bart-large",
            "--val_metric", "smatch",
            "--unified_input",
            "--output_dir", amr_output_dir,
            "--cache_dir", "/tmp",
            "--num_sanity_val_steps", "0",
            "--src_block_size", "256",
            "--tgt_block_size", "512",
            "--eval_max_length", "512",
            "--eval_num_workers", "0",
            "--process_num_workers", "1",
            "--do_eval",
            "--seed", "42",
            "--eval_beam", "5",
        ]

        call_amrbart = dynamic_import(Config.amr_script, Config.amr_script_entrypoint)
        call_amrbart(cmd_args, model_manager)

        with open(f"{amr_output_dir}/val_outputs/validation_predictions_0.txt") as f:
            return f.read()


@amr2text_celery.task
def run_amr_to_text(roots: List[AMRNode]) -> List[str]:
    """
    Each amr graph must be a rooted tree.
    Pass in the root nodes.
    """
    with TemporaryDirectory() as amr_input_dir, TemporaryDirectory() as amr_output_dir:
        with open(f"{amr_input_dir}/test.jsonl", "w") as amr_input_file:
            for root in roots:
                amr_input_file.write(json.dumps({"src": "", "tgt": root.to_spring()}))
                amr_input_file.write("\n")
        with open(f"{amr_input_dir}/train.jsonl", "w") as amr_input_file:
            amr_input_file.write(json.dumps({"src": "", "tgt": ""}) + "\n")
        with open(f"{amr_input_dir}/val.jsonl", "w") as amr_input_file:
            amr_input_file.write(json.dumps({"src": "", "tgt": ""}) + "\n")

        env = os.environ
        env["CUDA_VISIBLE_DEVICES"] = ""  # disable GPU
        env["OMP_NUM_THREADS"] = "3"
        # run amrbart
        cmd_args = [
            "--data_dir", amr_input_dir,
            "--train_data_file", amr_input_dir + "/train.jsonl",
            "--eval_data_file", amr_input_dir + "/val.jsonl",
            "--test_data_file", amr_input_dir + "/test.jsonl",
            "--model_type", Config.amr2text_model,
            "--model_name_or_path", Config.amr2text_model,
            "--tokenizer_name_or_path", "facebook/bart-large",
            "--val_metric", "bleu",
            "--max_epochs", "1",
            "--max_steps", "-1",
            "--unified_input",
            "--output_dir", amr_output_dir,
            "--cache_dir", "/tmp",
            "--num_sanity_val_steps", "0",
            "--src_block_size", "1024",
            "--tgt_block_size", "384",
            "--eval_max_length", "384",
            "--eval_num_workers", "0",
            "--process_num_workers", "1",
            "--do_eval",
            "--seed", "42",
            "--eval_beam", "5",
        ]

        call_amrbart = dynamic_import(
            Config.amr2text_script, Config.amr2text_script_entrypoint
        )
        call_amrbart(cmd_args, model_manager)

        with open(f"{amr_output_dir}/val_outputs/validation_predictions_0.txt") as f:
            return f.read().splitlines()


def parse_amr_output_file_content(content, should_simplify_graph=False, **kwargs) -> List[Tuple[str, AMRGraph]]:
    with open("penman.ebnf") as f:
        grammar = f.read()
    parser = Lark(grammar, start="amr_tree")

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
                tree = parse_single_amr_output(amr_output)
                graph = amr_tree_to_graph(tree, **kwargs)
                outputs.append((sent, graph))
                amr_output_lines = []
        else:
            amr_output_lines.append(line)
    return outputs


def parse_amr_output_file(filename, **kwargs):
    with open(filename) as f:
        return parse_amr_output_file_content(f.read(), **kwargs)


def parse_single_amr_output(amr_output) -> 'Tree':
    with open("penman.ebnf") as f:
        grammar = f.read()
    parser = Lark(grammar, start="amr_tree")
    tree = parser.parse(amr_output)
    return tree


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
        if value[0] == '"':
            value = value[1:-1]
        elif value in ("+", "-", "imperative", "expressive"):
            pass
        else:
            for transforms in (int, float):
                try:
                    value = transforms(value)
                    break
                except ValueError:
                    pass
        return AMRConstant(value)

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


def amr_tree_to_graph(tree: 'Tree', add_inv_edges_to_nodes=False) -> AMRGraph:
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
                if e.relationship.endswith("-of"):  # inverse relationship
                    e.relationship = e.relationship[:-3]
                    e.var1, e.var2 = e.var2, e.var1
                    if add_inv_edges_to_nodes:
                        inv_edges.append(e)
                edges.append(e)

    collect_nodes(amr_tree)
    collect_edges(amr_tree)
    for e in inv_edges: # if add_inv_edges_to_nodes
        for e in inv_edges:
            e.var1._edges.append(e)
    return AMRGraph(nodes, edges)


def simplify_graph(graph: AMRGraph):
    new_name_nodes = {}
    nodes_to_remove = set()
    edges = []
    for edge in graph.edges:
        if edge.relationship == 'wiki':
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
            i = 1 # this part is O(n^2) but I assume n is small enough
            while True:
                try:
                    op_edge = next(x for x in edge.var1._edges if x.relationship == f"op{i}")
                    parts.append(str(op_edge.var2.value))
                    nodes_to_remove.add(op_edge.var2.name)
                    i += 1
                except StopIteration:
                    break
            new_node = AMRConstant(" ".join(parts), "c"+name_node.name)
            new_name_nodes[name_node.name] = new_node
        else:
            edges.append(edge)
    for edge in edges:
        if edge.var2.name in new_name_nodes:
            edge.var2 = new_name_nodes[edge.var2.name]
    graph.edges = edges
    graph.nodes = [x for x in graph.nodes if x.name not in new_name_nodes and x.name not in nodes_to_remove] + list(new_name_nodes.values())
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


def extract_person_relations_from_file(filename):
    import json

    sent_and_graphs = parse_amr_output_file(filename, add_inv_edges_to_nodes=True)
    with open("cache/person_relations.txt", "w") as text_f, open(
        "cache/person_relations_spring.jsonl", "w"
    ) as spring_f:
        for sent, graph in sent_and_graphs:
            relations = extract_person_relations(graph)
            text_f.write(f"{sent}\n\n")
            for rel in relations:
                rel: AMRNode
                text_f.write(f"{rel.pretty_tree()}\n")
                spring_f.write(
                    json.dumps({"src": "", "tgt": rel.to_spring(), "sent": sent})
                )
                spring_f.write("\n")


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


def test_run():
    title = "Timeline: Google shutters Chinese site, moves to Hong Kong"
    # content = '''SHANGHAI  (Reuters) - Google Inc closed its China-based search service on Monday and began redirecting Web searchers to an uncensored site in Hong Kong, drawing harsh comments from Beijing that raised doubts about the company's future in the world's largest Internet market.
    #
    # Following are some key developments in Google's bumpy foray into China: 2000 - Google develops Chinese-language interface for its Google.com website. 2002 - Google.com becomes temporarily unavailable to Chinese users, with interference from domestic competition suspected. July 2005 - Google hires ex-Microsoft executive Lee Kai Fu as head of Google China. Microsoft sues Google over the move, claiming Lee will inevitably disclose propriety information to Google. The two rivals reach a settlement on the suit over Lee in December. Jan 2006 - Google rolls out Google.cn, its China-based search page that, in accordance with Chinese rules, censors search results. Google says it made the trade-off to "make meaningful and positive contributions" to development in China while abiding by the country's strict censorship laws. Aug 2008 - Google launches free music downloads for users in China to better compete with market leader Baidu Inc. March 2009 - China blocks access to Google's YouTube video site. June 2009 - A Chinese official accuses Google of spreading obscene content over the Internet. The comments come a day after Google.com, Gmail and other Google online services became inaccessible to many users in China. Sept 2009 - Lee resigns as Google China head to start his own company. Google appoints sales chief John Liu to take over Lee's business and operational responsibilities. Oct 2009 - A group of Chinese authors accuses Google of violating copyrights with its digital library, with many threatening to sue. Jan 2010 - Google announces it is no longer willing to censor searches in China and may pull out of the country. Jan 2010 - Google postpones launch of two Android phones in China. Feb 2010 - The New York Times reports the hacking attacks on Google had been traced to two schools in China, citing people familiar with the investigation. The schools deny involvement. March 22, 2010 - Google announces it will move its mainland Chinese-language portal and begin rerouting searches to its Hong Kong-based site.'''
    content = "A quick brown fox jumps jumps over the lazy dog."
    run_amr_parsing(title, content)


def test_parse_single():
    text = """(z0 / page
    :medium-of (z1 / search-01)
    :ARG1-of (z2 / base-01
                 :location (z3 / country
                               :wiki "China"
                               :name (z4 / name
                                         :op1 "China")))
    :ARG0-of (z5 / censure-01
                 :ARG1 (z6 / result
                           :mod z1)
                 :ARG1-of (z7 / accord-02
                              :ARG2 (z8 / rule
                                        :mod z3)))
    :poss (z9 / company
              :wiki "Google"
              :name (z10 / name
                         :op1 "Google.cn")))"""
    tree = parse_single_amr_output(text)
    print(tree.pretty())

    amr_tree_to_graph(tree)


def test_parse_full():
    def dictify(obj):
        if isinstance(obj, dict):
            return {k: dictify(v) for k, v in obj.items()}
        elif isinstance(obj, list):
            return [dictify(v) for v in obj]
        elif is_dataclass(obj):
            return obj.asdict()  # assume custom asdict is implemented
        else:
            return obj

    import json

    output = parse_amr_output_file("cache/validation_predictions_0.txt")
    output = [{"sentence": sent, "graph": dictify(graph)} for sent, graph in output]
    with open("cache/graphs.json", "w") as f:
        json.dump(output, f, indent=2)


def test_polarity():
    text = """(z0 / obligate-01
   :ARG2 (z1 / go-02
            :ARG0 (z2 / boy)
            :polarity -))"""
    tree = parse_single_amr_output(text)
    graph = amr_tree_to_graph(tree)
    print(tree.pretty())


def test_person_rel():
    text = """
(z0 / appoint-01
    :ARG0 (z1 / company
              :wiki "Google"
              :name (z2 / name
                        :op1 "Google"))
    :ARG1 (z3 / person
              :wiki -
              :name (z4 / name
                        :op1 "John"
                        :op2 "Liu")
              :ARG0-of (z5 / have-org-role-91
                           :ARG1 z1
                           :ARG2 (z6 / chief
                                     :topic (z7 / sell-01))))
    :ARG2 (z8 / take-over-12
              :ARG0 z3
              :ARG1 (z9 / and
                        :op1 (z10 / responsible-03
                                  :ARG0 (z11 / person
                                             :wiki -
                                             :name (z12 / name
                                                        :op1 "Lee"))
                                  :ARG1 (z13 / business))
                        :op2 (z14 / responsible-03
                                  :ARG0 z11
                                  :ARG1 (z15 / operate-01)))))
    """
    tree = parse_single_amr_output(text)
    graph = amr_tree_to_graph(tree, add_inv_edges_to_nodes=True)
    relations = extract_person_relations(graph)
    for r in relations:
        r.print_tree()
        print(r.to_spring())


def test_person_rel_full():
    extract_person_relations_from_file("cache/AMR-jnQqSH8B-NK2HObsTr5c.txt")


if __name__ == "__main__":
    # test_run()
    import logging
    import os
    import torch

    if torch.cuda.is_available():
        torch.cuda.set_device(torch.device("cuda:0"))

    logging.getLogger("penman.layout").setLevel("CRITICAL")

    if os.environ.get("AMRPARSING_RPC"):
        amr_parsing_celery.start(argv=["worker", "-l", "INFO", "--concurrency=1", "-Q", "amr_parsing", "-P", "solo", "-n", "amr-parsing-worker@%n"])
    elif os.environ.get("AMR2TEXT_RPC"):
        amr2text_celery.start(argv=["worker", "-l", "INFO", "--concurrency=1", "-Q", "amr2text", "-P", "solo", "-n", "amr2text-worker@%n"])
    else:
        raise ValueError("No RPC server specified in environment variables")
