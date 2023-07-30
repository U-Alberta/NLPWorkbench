import pickle

from ..rpc import create_celery
from ..config import Config
from ..utils import Models

try:
    import fasttext
    import torch
    import numpy as np
    import pandas as pd
    from .auto_processor import AutoProcessor
    from .model_for_multi_label import ModelForMultiLable
    from transformers import AutoConfig, AutoModelForSequenceClassification

    from .bert_processor import BertProcessor
    from .bert_for_multi_label import BertForMultiLabel
except ImportError as e:
    import os

    if os.environ.get("RPC_CALLER") is None:
        raise e

celery = create_celery("workbench.classifier", "classifier")


@celery.task
def run_multiclass_crime_classifier(text):
    if not Models.get_preloaded_model("multiclass-classifier"):
        with open(Config.crime_multiclass_model, "rb") as f:
            Models.save_preloaded_model("multiclass-classifier", pickle.load(f))
    # multiclass predict
    multiclass_model = Models.get_preloaded_model("multiclass-classifier")
    multiclass_label = multiclass_model.predict(text)
    #print(multiclass_label)
    if multiclass_label == "irrelevant":
        multiclass_label = "Non Crime"
    return multiclass_label


@celery.task
def run_multiclass_one_vs_rest_crime_classifier(text):
    if not Models.get_preloaded_model("multiclass-classifier-OneVsRest"):
        with open(Config.crime_multiclass_model_OneVsRest, "rb") as f:
            Models.save_preloaded_model(
                "multiclass-classifier-OneVsRest", pickle.load(f)
            )
    # multiclass predict
    multiclass_model = Models.get_preloaded_model("multiclass-classifier-OneVsRest")
    multiclass_label = multiclass_model.predict(text)
    #print(multiclass_label)
    if multiclass_label == "irrelevant":
        multiclass_label = "Non Crime"
    return multiclass_label


@celery.task
def run_multilabel_crime_classifier(text):
    if not Models.get_preloaded_model("multilabel-classifier"):
        Models.save_preloaded_model(
            "multilabel-classifier", fasttext.load_model(Config.crime_multilabel_model)
        )
    # multilabel predict
    multilabel_model = Models.get_preloaded_model("multilabel-classifier")
    predicted = multilabel_model.predict(text, k=-1, threshold=0.01)[0][0]
    labels = []
    for i in predicted:
        h = i.split("__")[-1]
        labels.append(h)
    return labels


@celery.task
def run_multilabel_transformer_based_classifier(text, model_name):
    #print(text)
    config_model = {
        "albert-base-v2": {
            "max_seq_length": 256,
            "do_lower_case": True,
            "arch": "albert-base-v2",
            "threshold": 0.25,
            "add_layers": 1,
            "path": "/app/models/albert-base-v2/",
        },
        "bert-base-uncased": {
            "max_seq_length": 256,
            "do_lower_case": True,
            "arch": "bert-base-uncased",
            "threshold": 0.25,
            "add_layers": 1,
            "path": "/app/models/bert-base-uncased/",
        },
        "ProsusAI-finbert": {
            "max_seq_length": 256,
            "do_lower_case": True,
            "arch": "ProsusAI/finbert",
            "threshold": 0.275,
            "add_layers": 1,
            "path": "/app/models/ProsusAI-finbert/",
        },
        "openai-gpt": {
            "max_seq_length": 256,
            "do_lower_case": True,
            "arch": "openai-gpt",
            "threshold": 0.355,
            "add_layers": 0,
            "path": "/app/models/openai-gpt/",
        },
    }
    config = config_model[model_name]
    MODEL_KEY = model_name
    if not Models.get_preloaded_model(MODEL_KEY):
        processor = AutoProcessor(
            pretrained_model_name_or_path=config["arch"],
            do_lower_case=config["do_lower_case"],
        )
        label_list = processor.get_labels()
        id2label = {i: label for i, label in enumerate(label_list)}
        model_config = AutoConfig.from_pretrained(
            pretrained_model_name_or_path=config["path"], num_labels=len(label_list)
        )
        if config["add_layers"] == 0:
            model = AutoModelForSequenceClassification.from_pretrained(
                pretrained_model_name_or_path=config["path"],
                config=model_config,
                ignore_mismatched_sizes=True,
            )
        else:
            model = ModelForMultiLable.from_pretrained(
                pretrained_model_name_or_path=config["path"],
                config=model_config,
                ignore_mismatched_sizes=True,
                arch=config["arch"],
            )

        # model = BertForMultiLabel.from_pretrained("/app/models/bert" , num_labels=len(label_list))
        Models.save_preloaded_model(MODEL_KEY, (processor, label_list, model))
    else:
        processor, label_list, model = Models.get_preloaded_model(MODEL_KEY)

    tokens = processor.tokenizer.tokenize(text)
    if len(tokens) > config["max_seq_length"] - 2:
        tokens = tokens[: config["max_seq_length"] - 2]
    tokens = ["[CLS]"] + tokens + ["[SEP]"]
    input_ids = processor.tokenizer.convert_tokens_to_ids(tokens)
    input_ids = torch.tensor(input_ids).unsqueeze(0)  # Batch size 1, 2 choices

    if config["add_layers"] == 0:
        logits = model(input_ids).logits
    else:
        logits = model(input_ids)

    probs = logits.sigmoid().data.cpu().numpy()
    #print(probs)
    print(
        "--------------------------------------------------------------------------------------"
    )
    target_list = pd.Series(
        [
            "Drug Trafficking",
            "Tax",
            "Health Care Fraud",
            "Public Corruption",
            "Violent Crime",
            "Counterterrorism",
            "Project Safe Childhood",
            "Hate Crimes",
            "Financial Fraud",
            "Indian Country Law and Justice",
            "Human Trafficking",
            "Asset Forfeiture",
            "Disaster Fraud",
            "Securities, Commodities, & Investment Fraud",
            "Foreign Corruption",
            "Identity Theft",
            "Human Smuggling",
            "Mortgage Fraud",
            "Bankruptcy",
            "NonCrime",
        ]
    )

    y_pred = (probs > config["threshold"]).astype(int)
    predicted_labels = target_list[y_pred[0] == 1].values
    sorted_prob = probs.argpartition(-2)[:, -2]
    # print(sorted_prob)
    if len(predicted_labels) == 0:
        predicted_labels = [target_list[np.argmax(probs)]]
        predicted_labels.append(target_list[sorted_prob[0]])
        predicted_labels.append(target_list[probs.argpartition(-3)[:, -3][0]])

    else:
        predicted_labels = predicted_labels.tolist()
    # print(predicted_labels)
    # print(type(predicted_labels))
    return predicted_labels


@celery.task
def run_multilabel_bert_crime_classifier(
    text, max_seq_length=512, do_lower_case=True, threshold=0.26
):
    MODEL_KEY = "multilabel-bert"
    if not Models.get_preloaded_model(MODEL_KEY):
        processor = BertProcessor(
            vocab_path="/app/models/bert/bert_vocab.txt", do_lower_case=do_lower_case
        )
        label_list = processor.get_labels()
        model = BertForMultiLabel.from_pretrained(
            "/app/models/bert", num_labels=len(label_list)
        )
        Models.save_preloaded_model(MODEL_KEY, (processor, label_list, model))
    else:
        processor, label_list, model = Models.get_preloaded_model(MODEL_KEY)

    tokens = processor.tokenizer.tokenize(text)
    if len(tokens) > max_seq_length - 2:
        tokens = tokens[: max_seq_length - 2]
    tokens = ["[CLS]"] + tokens + ["[SEP]"]
    input_ids = processor.tokenizer.convert_tokens_to_ids(tokens)
    input_ids = torch.tensor(input_ids).unsqueeze(0)  # Batch size 1, 2 choices
    logits = model(input_ids)
    probs = logits.sigmoid().data.cpu().numpy()
    target_list = pd.Series(
        [
            "Drug Trafficking",
            "Tax",
            "Health Care Fraud",
            "Public Corruption",
            "Violent Crime",
            "Counterterrorism",
            "Project Safe Childhood",
            "Hate Crimes",
            "Financial Fraud",
            "Indian Country Law and Justice",
            "Human Trafficking",
            "Asset Forfeiture",
            "Disaster Fraud",
            "Securities, Commodities, & Investment Fraud",
            "Foreign Corruption",
            "Identity Theft",
            "Human Smuggling",
            "Mortgage Fraud",
            "Bankruptcy",
            "NonCrime",
        ]
    )

    y_pred = (probs > threshold).astype(int)
    predicted_labels = list(target_list[y_pred[0] == 1].values)
    if len(predicted_labels) == 0:
        predicted_labels = ["NonCrime"]

    # print(predicted_labels)

    return predicted_labels
