from elasticsearch import RequestError, NotFoundError
import pytest

from workbench.wsgi import create_app
from workbench.bing_search import search_topk_webpages, search_topk_news
from workbench.coll.collection_api import create_index, delete_index, import_from_json
import os

bing_key = os.environ["BING_KEY"]


@pytest.fixture()
def app():
    app = create_app()
    app.config.update({"TESTING": True, "BING_KEY": os.environ["BING_KEY"]})
    # other setup can go here

    try:
        create_index("testing", "")
    except RequestError:
        pass

    yield app
    # clean up / reset resources here
    try:
        delete_index("testing")
    except (RequestError, NotFoundError):
        pass


@pytest.fixture()
def client(app):
    return app.test_client()


@pytest.fixture()
def document(app):
    text = """
    Justin Pierre James Trudeau (born December 25, 1971) is a Canadian politician serving as the 23rd and current prime minister of Canada since 2015 and leader of the Liberal Party since 2013. Trudeau is the second-youngest prime minister in Canadian history after Joe Clark; he is also the first to be the child of a previous holder of the post, as the eldest son of Pierre Trudeau.
    Trudeau was born in Ottawa and attended Collège Jean-de-Brébeuf. He graduated from McGill University in 1994 with a Bachelor of Arts degree in literature, then in 1998 acquired a Bachelor of Education degree from the University of British Columbia. After graduating he taught at the secondary school level in Vancouver, before relocating back to Montreal in 2002 to further his studies. He was chair for the youth charity Katimavik and director of the not-for-profit Canadian Avalanche Association. In 2006, he was appointed as chair of the Liberal Party's Task Force on Youth Renewal.
    """
    ids = import_from_json(
        "testing", {"doc": [{"text": text, "title": "Justin Trudeau - Wikipedia"}]}
    )
    return ids[0]


def test_hello_world(client):
    response = client.get("/")
    assert b"It's working!" == response.data


def test_import_from_url(client):
    article_url = "https://en.wikinews.org/wiki/First_NASA_TROPICS_satellites_launch_to_monitor_tropical_storms?dpl_id=2971362"
    resp = client.post(
        "/collection/testing/doc/_import_from_url", json={"url": article_url}
    )
    doc = resp.json
    assert len(doc["title"]) > 0

    resp = client.get(f"/collection/testing/doc/{doc['id']}")
    assert resp.status_code == 200
    assert doc["text"] == resp.json["text"]


def test_top_k_webpages():
    topk = 5
    resp = search_topk_webpages("Canada", "en-CA", bing_key, freshness="Any", topk=topk)
    assert resp["total_matches"] > 0
    assert len(resp["docs"]) == topk


def test_top_k_news():
    topk = 5
    resp = search_topk_news(
        "Edmonton Oilers", "en-CA", bing_key, freshness="Any", topk=topk
    )
    assert resp["total_matches"] > 0
    assert len(resp["docs"]) == min(topk, resp["total_matches"])


def test_relation_extraction(client, document):
    response = client.get(f"/collection/testing/doc/{document}/relation").json
    assert len(response) > 0
