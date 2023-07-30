import json
import argparse
import os
import sys
import random
import logging
import time
from tqdm import tqdm
import numpy as np

from shared.data_structures import Dataset
from shared.const import task_ner_labels, get_labelmap
from entity.utils import convert_dataset_to_samples, batchify, NpEncoder
from entity.models import EntityModel

from transformers import AdamW, get_linear_schedule_with_warmup
import torch

logging.basicConfig(
    format="%(asctime)s - %(levelname)s - %(name)s - %(message)s",
    datefmt="%m/%d/%Y %H:%M:%S",
    level=logging.INFO,
)
logger = logging.getLogger("root")


def output_ner_predictions(model: EntityModel, batches, dataset, output_file):
    global ner_id2label

    """
    Save the prediction as a json file
    """
    ner_result = {}
    span_hidden_table = {}
    tot_pred_ett = 0
    for i in range(len(batches)):
        try:
            output_dict = model.run_batch(batches[i], training=False)
        except AssertionError:
            continue
        pred_ner = output_dict["pred_ner"]
        for sample, preds in zip(batches[i], pred_ner):
            off = sample["sent_start_in_doc"] - sample["sent_start"]
            k = sample["doc_key"] + "-" + str(sample["sentence_ix"])
            ner_result[k] = []
            for span, pred in zip(sample["spans"], preds):
                span_id = "%s::%d::(%d,%d)" % (
                    sample["doc_key"],
                    sample["sentence_ix"],
                    span[0] + off,
                    span[1] + off,
                )
                if pred == 0:
                    continue
                ner_result[k].append([span[0] + off, span[1] + off, ner_id2label[pred]])
            tot_pred_ett += len(ner_result[k])

    logger.info("Total pred entities: %d" % tot_pred_ett)

    js = dataset.js
    for i, doc in enumerate(js):
        doc["predicted_ner"] = []
        doc["predicted_relations"] = []
        for j in range(len(doc["sentences"])):
            k = doc["doc_key"] + "-" + str(j)
            if k in ner_result:
                doc["predicted_ner"].append(ner_result[k])
            else:
                doc["predicted_ner"].append([])

            doc["predicted_relations"].append([])

        js[i] = doc

    logger.info("Output predictions to %s.." % (output_file))
    with open(output_file, "a") as f:
        f.write("\n".join(json.dumps(doc, cls=NpEncoder) for doc in js))


def setseed(seed):
    random.seed(seed)
    torch.manual_seed(seed)
    if torch.cuda.is_available():
        torch.cuda.manual_seed_all(seed)


def call(cmd_args=None, model_manager=None):
    global ner_id2label, ner_label2id
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--task",
        type=str,
        default="ace05",
        required=False,
        choices=["ace04", "ace05", "scierc"],
    )
    parser.add_argument(
        "--test_data",
        type=str,
        default=None,
        required=True,
        help="path to the preprocessed dataset",
    )
    parser.add_argument(
        "--model_dir",
        type=str,
        default=None,
        required=True,
        help="directory of the pretrained entity model",
    )
    parser.add_argument(
        "--test_pred_filename",
        type=str,
        default="ent_pred_test.json",
        help="the prediction filename for the test set",
    )
    parser.add_argument(
        "--output_dir",
        type=str,
        default=None,
        required=True,
        help="directory for log outputs",
    )

    # TODO: tune this
    parser.add_argument(
        "--max_span_length",
        type=int,
        default=8,
        help="spans w/ length up to max_span_length are considered as candidates",
    )

    parser.add_argument(
        "--eval_batch_size", type=int, default=32, help="batch size during inference"
    )
    parser.add_argument(
        "--eval_per_epoch",
        type=int,
        default=1,
        help="how often evaluating the trained model on dev set during training",
    )
    parser.add_argument(
        "--bertadam",
        action="store_true",
        help="If bertadam, then set correct_bias = False",
    )

    parser.add_argument(
        "--use_albert", action="store_true", help="whether to use ALBERT model"
    )
    parser.add_argument(
        "--model",
        type=str,
        default="bert-base-uncased",
        help="the base model name (a huggingface model)",
    )
    parser.add_argument(
        "--bert_model_dir", type=str, default=None, help="the base model directory"
    )

    parser.add_argument("--seed", type=int, default=0)

    parser.add_argument(
        "--context_window",
        type=int,
        required=False,
        default=300,
        help="the context window size W for the entity model",
    )

    args = parser.parse_args(cmd_args)

    if "albert" in args.model:
        logger.info("Use Albert: %s" % args.model)
        args.use_albert = True

    setseed(args.seed)

    if not os.path.exists(args.output_dir):
        os.makedirs(args.output_dir)

    logger.addHandler(
        logging.FileHandler(os.path.join(args.output_dir, "eval.log"), "w")
    )

    logger.info(sys.argv)
    logger.info(args)

    ner_label2id, ner_id2label = get_labelmap(task_ner_labels[args.task])

    num_ner_labels = len(task_ner_labels[args.task]) + 1
    args.bert_model_dir = args.model_dir

    model = None
    if model_manager is not None:
        model = model_manager.get_preloaded_model("ner")
    if model is None:
        model = EntityModel(args, num_ner_labels=num_ner_labels)
        if model_manager is not None:
            model_manager.save_preloaded_model("ner", model)

    test_data = Dataset(args.test_data)
    prediction_file = args.test_pred_filename

    logger.info("Override output file.")
    with open(prediction_file, "w") as f:
        pass

    for chunk in tqdm(test_data.chunks(100)):
        test_samples, test_ner = convert_dataset_to_samples(
            chunk,
            args.max_span_length,
            ner_label2id=ner_label2id,
            context_window=args.context_window,
        )
        test_batches = batchify(test_samples, args.eval_batch_size)
        output_ner_predictions(
            model, test_batches, test_data, output_file=prediction_file
        )


"""
python3 run_ner.py --model bert-base-uncased --test_data /data/news/ner/reuters.json --model_dir /data/ner/ent-bert-ctx300 --test_pred_filename /data/news/ner/output/reuters-ner.json --output_dir logs --context_window 300
"""

if __name__ == "__main__":
    call()
