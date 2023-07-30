import os
import logging
from typing import *

import requests
import backoff

# api_key = os.environ["BING_KEY"]


class BingAPIError(Exception):
    def __init__(self, message):
        self.message = message


class BingAPIRateLimitError(BingAPIError):
    def __init__(self, message):
        super().__init__(message)


@backoff.on_exception(backoff.expo, BingAPIRateLimitError, max_time=60)
def search_news(q, mkt, key, category=None, freshness=None, count=10, offset=0):
    """
    Make a single API call
    """
    endpoint = "https://api.bing.microsoft.com/v7.0/news/search"
    headers = {"Ocp-Apim-Subscription-Key": key}
    req = {
        "q": q,
        "mkt": mkt,
        "count": count,
        "offset": offset,
        "freshness": freshness,
        "count": count,
        "offset": offset,
    }
    if freshness == "Any":
        del req["freshness"]
    if category and category != "Any":
        req["category"] = category
    r = requests.get(endpoint, params=req, headers=headers)
    if r.status_code == 429:
        logging.error("Per second quota exceeded")
        logging.error(r.text)
        raise BingAPIRateLimitError(
            "The caller exceeded their queries per second quota."
        )
    elif r.status_code != 200:
        logging.error(r.status_code)
        logging.error(r.text)
        try:
            if "error" in r.json:
                err_msg = r.json["error"]["message"]
            else:
                errors = [x["message"] for x in r.json["errors"]]
                err_msg = " ".join(errors)
            raise BingAPIError(f"Error calling Bing API. {err_msg}")
        except:
            raise BingAPIError("Error calling Bing API.")
    api_resp = r.json()
    if "totalEstimatedMatches" not in api_resp:  # no more results
        return {"total_matches": 0, "docs": []}
    resp = {
        "total_matches": api_resp["totalEstimatedMatches"],
        "docs": api_resp["value"],
    }
    for doc in resp["docs"]:
        # remove unnecessary fields
        for k in (
            "about",
            "clusteredArticles",
            "contractualRules",
            "headline",
            "id",
            "image",
            "video",
            "mentions",
        ):
            if k in doc:
                del doc[k]
        doc["provider"] = [x["name"] for x in doc["provider"]]
    return resp


@backoff.on_exception(backoff.expo, BingAPIRateLimitError, max_time=60)
def search_webpage(
    q,
    mkt,
    key,
    freshness=None,
    count=10,
    offset=0,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
):
    """
    Make a single API call
    """
    endpoint = "https://api.bing.microsoft.com/v7.0/search"
    headers = {"Ocp-Apim-Subscription-Key": key}
    req = {
        "q": q,
        "mkt": mkt,
        "count": count,
        "offset": offset,
        "freshness": freshness,
        "count": count,
        "offset": offset,
        "responseFilter": "Webpages",
    }
    if freshness == "Custom":
        if start_date == end_date:
            req["freshness"] = start_date
        else:
            req["freshness"] = f"{start_date}..{end_date}"
    elif freshness == "Any":
        del req["freshness"]
    r = requests.get(endpoint, params=req, headers=headers)
    if r.status_code == 429:
        logging.error("Per second quota exceeded")
        logging.error(r.text)
        raise BingAPIRateLimitError(
            "The caller exceeded their queries per second quota."
        )
    elif r.status_code != 200:
        try:
            errors = [x["message"] for x in r.json["errors"]]
            raise BingAPIError(f"Error calling Bing API. {' '.join(errors)}")
        except:
            raise BingAPIError("Error calling Bing API.")
    if "webPages" not in r.json():  # no more results
        return {"total_matches": 0, "docs": [], "bing_url": ""}
    api_resp = r.json()["webPages"]
    resp = {
        "total_matches": api_resp["totalEstimatedMatches"],
        "docs": api_resp["value"],
        "bing_url": api_resp["webSearchUrl"],
    }
    for doc in resp["docs"]:
        # remove unnecessary fields
        for k in list(doc.keys()):
            if k not in ("name", "snippet", "url"):
                del doc[k]
    return resp


def search_topk_news(
    q,
    mkt,
    key,
    category=None,
    freshness=None,
    topk=10,
):
    resp = {"total_matches": 100000000, "docs": []}  # initialize as infinity
    offset = 0
    while offset < topk and offset < resp["total_matches"]:
        bing_api_resp = search_news(
            q,
            mkt,
            key,
            category,
            freshness,
            count=min(topk - offset, 50),
            offset=offset,
        )
        if len(bing_api_resp["docs"]) == 0:
            break
        resp["total_matches"] = bing_api_resp["total_matches"]
        resp["docs"].extend(bing_api_resp["docs"])
        offset += len(bing_api_resp["docs"])
    return resp


def search_topk_webpages(
    q,
    mkt,
    key,
    freshness=None,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    topk=10,
):
    resp = {"total_matches": 100000000, "docs": []}  # initialize as infinity
    offset = 0
    while offset < topk and offset < resp["total_matches"]:
        bing_api_resp = search_webpage(
            q,
            mkt,
            key,
            freshness,
            start_date=start_date,
            end_date=end_date,
            count=min(topk - offset, 50),
            offset=offset,
        )
        if len(bing_api_resp["docs"]) == 0:
            break
        resp["total_matches"] = bing_api_resp["total_matches"]
        resp["docs"].extend(bing_api_resp["docs"])
        offset += len(bing_api_resp["docs"])
    return resp
