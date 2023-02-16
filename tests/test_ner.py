from pathlib import Path

from workbench import ner

def load_document():
    with open(Path(__file__).parent / "sample-document.txt", "r") as f:
        lines = f.readlines()
        title, *content = lines
        content = "\n".join(content)
        return title, content


def test_sentence_extraction():
    title = "This is a title."
    content = """This is a sentence. This is a sentence.

This is another sentence. This is another sentence."""
    sentences, pos = ner.extract_sentences(title, content)
    assert len(sentences) == 5
    assert len(pos) == 5
    assert sentences[0] == ["This", "is", "a", "title", "."]
    for sent, sent_pos in zip(sentences, pos):
        assert sent_pos == ["DET", "VERB", "DET", "NOUN", "PUNCT"], sent


def test_ner():
    title, content = load_document()
    paragraph = ner.run_ner(title, content)
    # test if "Google" is recognized as an ORG
    google_recognized = False
    for sent in paragraph:
        for token in sent:
            if isinstance(token, ner.EntityMention):
                if token.text == "Google" and token.type == "ORG":
                    google_recognized = True
    assert google_recognized

    # for the test sentence "2000 - Google develops Chinese-language interface for its Google.com website."
    # "its" should be resovled to Google
    paragraph = ner.resolve_coreferences(paragraph)
    pron_resolved = False
    for sent in paragraph:
        for token in sent:
            if isinstance(token, ner.Coreference):
                if token.text == "its" and token.entity.text == "Google":
                    pron_resolved = True
    assert pron_resolved