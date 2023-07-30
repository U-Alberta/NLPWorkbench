from pathlib import Path

from workbench import semantic


def load_document():
    with open(Path(__file__).parent / "sample-document.txt", "r") as f:
        lines = f.readlines()
        title, *content = lines
        content = "\n".join(content)
        return title, content


def test_parsing():
    title, content = load_document()
    raw_amrbart_output = semantic.run_amr_parsing(title, content)
    print("raw_amrbart_output", raw_amrbart_output)
    trees = semantic.parse_amr_output_file_content(raw_amrbart_output)
    assert len(trees) > 0
