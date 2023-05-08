import pytest
from workbench.wsgi import create_app
from workbench.bing_search import search_topk_webpages, search_topk_news


@pytest.fixture()
def app():
    app = create_app()
    app.config.update({
        "TESTING": True,
    })
    # other setup can go here
    yield app
    # clean up / reset resources here


@pytest.fixture()
def client(app):
    return app.test_client()


def test_hello_world(client):
    response = client.get('/')
    assert b"It's working!" == response.data


def test_top_k_webpages():
    resp = search_topk_webpages("Canada", "en-CA", freshness="Any", topk=80)
    assert resp["total_matches"] > 0
    assert len(resp["docs"]) == 80 


def test_top_k_news():
    resp = search_topk_news("Edmonton Oilers", "en-CA", freshness="Any", topk=80)
    assert resp["total_matches"] > 0
    assert len(resp["docs"]) == min(80, resp["total_matches"])