if __name__ == "__main__":
    from . import celery

    celery.start(
        argv=["worker", "-l", "INFO", "-Q", "classifier", "-P", "solo", "-c", "1"]
    )
