from workbench import vader


def test_classify_positive_sents():
    positive_sents = [
        "I love this product.",
        "Fantastic!",
        "I am so happy.",
        "This is a great movie.",
    ]
    for sent in positive_sents:
        output = vader.run_vader(sent)
        assert output["polarity_compound"] > 0.3


def test_classify_negative_sents():
    negative_sents = [
        "I hate this product.",
        "This is not good",
        "This song is terrible.",
        "The product is performing worse than we expected.",
    ]
    for sent in negative_sents:
        output = vader.run_vader(sent)
        assert output["polarity_compound"] < -0.3, sent


def test_classify_neutral_sents():
    neutral_sents = [
        "One plus one equals two.",
        "Edmonton is the capital of Alberta.",
        "I am a student.",
        "I am a student in the University of Alberta.",
    ]
    for sent in neutral_sents:
        output = vader.run_vader(sent)
        assert -0.3 <= output["polarity_compound"] <= 0.3
