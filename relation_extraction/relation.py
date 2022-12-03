import logging
import sys

# from utils import Models
# from rpc import create_celery
from run import run_batch


# @celery.task
def run_re(title: str, content: str):
    logging.info("run re")
    contents = title + " " + content
    outputs = [] 
    for fact in run_batch([contents])[0]:
      if fact.has_positive_label():
        outputs.append(fact)

    return outputs
  
def test_re():
    title = "Cardy resigns as N.B. education minister, sends scorching letter to premier."
    content = "Dominic Cardy has resigned as New Brunswick's minister of education and early childhood development. 1+1=2. Cardy announced in a tweet that he was quitting the cabinet of Premier Blaine Higgs but would stay on as a Progressive Conservative MLA for Fredericton West-Hanwell."
    print(run_re(title, content))


if __name__ == "__main__":
    # celery.start(argv=["-A", "relation", "worker", "-l", "INFO", "-Q", "relation"])
    test_re()
  
