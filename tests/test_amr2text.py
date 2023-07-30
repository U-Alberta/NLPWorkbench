from pathlib import Path

from workbench import semantic


def load_amr():
    with open(Path(__file__).parent / "sample-amr.txt", "r") as f:
        return f.read()


def test_person_relation_extraction():
    amr_content = load_amr()
    sents_and_graphs = semantic.parse_amr_output_file_content(
        amr_content, add_inv_edges_to_nodes=True
    )
    sents = []
    rel_graphs = []
    for sent, graph in sents_and_graphs:
        relations = semantic.extract_person_relations(graph)
        for rel in relations:
            sents.append(sent)
            rel_graphs.append(rel)
    assert len(sents) > 0
    assert len(rel_graphs) > 0
    texts = semantic.run_amr_to_text(rel_graphs)
    assert len(sents) == len(texts) == len(rel_graphs)
