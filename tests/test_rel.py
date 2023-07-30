import pytest

from workbench import relation_extraction
from workbench.ner import extract_sentences


@pytest.fixture
def document():
    title = "Justin Trudeau"
    content = """
    Justin Pierre James Trudeau (born December 25, 1971) is a Canadian politician serving as the 23rd and current prime minister of Canada since 2015 and leader of the Liberal Party since 2013. Trudeau is the second-youngest prime minister in Canadian history after Joe Clark; he is also the first to be the child of a previous holder of the post, as the eldest son of Pierre Trudeau.
    Trudeau was born in Ottawa and attended Collège Jean-de-Brébeuf. He graduated from McGill University in 1994 with a Bachelor of Arts degree in literature, then in 1998 acquired a Bachelor of Education degree from the University of British Columbia. After graduating he taught at the secondary school level in Vancouver, before relocating back to Montreal in 2002 to further his studies. He was chair for the youth charity Katimavik and director of the not-for-profit Canadian Avalanche Association. In 2006, he was appointed as chair of the Liberal Party's Task Force on Youth Renewal.
    """
    predicted_ner = [
        [[0, 1, "PER"]],
        [
            [2, 5, "PER"],
            [15, 15, "GPE"],
            [16, 16, "PER"],
            [24, 24, "PER"],
            [26, 26, "GPE"],
            [30, 30, "PER"],
            [33, 34, "ORG"],
        ],
        [
            [38, 38, "PER"],
            [45, 45, "PER"],
            [47, 47, "GPE"],
            [50, 51, "PER"],
            [53, 53, "PER"],
            [57, 57, "PER"],
            [61, 61, "PER"],
            [65, 65, "PER"],
            [73, 73, "PER"],
            [75, 76, "PER"],
        ],
        [[78, 78, "PER"], [82, 82, "GPE"]],
        [[92, 92, "PER"], [95, 96, "ORG"], [119, 122, "ORG"]],
        [
            [126, 126, "PER"],
            [131, 131, "ORG"],
            [134, 134, "GPE"],
            [140, 140, "GPE"],
            [145, 145, "PER"],
        ],
        [
            [148, 148, "PER"],
            [150, 150, "PER"],
            [154, 154, "ORG"],
            [155, 155, "ORG"],
            [157, 157, "PER"],
            [165, 167, "ORG"],
        ],
        [[172, 172, "PER"], [176, 176, "PER"], [179, 180, "ORG"], [185, 185, "PER"]],
    ]
    sents, _ = extract_sentences(title, content)
    return sents, predicted_ner


def test_relation_extraction(document):
    sents, predicted_ner = document
    relations = relation_extraction.run_rel(sents, predicted_ner)
    assert len(relations) > 0
