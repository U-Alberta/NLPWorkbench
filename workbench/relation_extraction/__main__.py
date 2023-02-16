if __name__ == "__main__":
    from . import celery
    #sents = [
    #    "Cardy resigns as N.B. education minister, sends scorching letter to premier.",
    #    "Dominic Cardy has resigned as New Brunswick's minister of education and early childhood development.",
    #    "1+1=2",
    #    "Cardy announced in a tweet that he was quitting the cabinet of Premier Blaine Higgs but would stay on as a Progressive Conservative MLA for Fredericton West-Hanwell.",
    #]
    #print(run_batch(sents))


    celery.start(
        argv=["worker", "-l", "INFO", "-Q", "relation", "-P", "solo", "-c", "1"]
    )
