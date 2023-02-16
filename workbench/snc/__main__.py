from . import celery, run_snc

if __name__ == '__main__':
    celery.start(argv=["worker", "-l", "INFO", "--concurrency=1", "-Q", "snc"])