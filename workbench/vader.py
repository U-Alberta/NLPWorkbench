import logging

from .utils import Models
from .rpc import create_celery

celery = create_celery("workbench.vader", "vader")


@celery.task
def run_vader(content):
    logging.info("run vader")

    # should not throw key error
    score = Models.vader().polarity_scores(content)["compound"]
    vader_output = {"polarity_compound": score}
    return vader_output


if __name__ == "__main__":
    celery.start(argv=["-A", "workbench.vader", "worker", "-l", "INFO", "-Q", "vader"])
