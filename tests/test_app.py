import pytest

from app.logic import add, is_palindrome
from app.main import app


@pytest.fixture
def client():
    app.config["TESTING"] = True
    return app.test_client()


def test_add():
    assert add(2, 3) == 5
    assert add(-1, 1) == 0


def test_is_palindrome():
    assert is_palindrome("A man, a plan, a canal: Panama")
    assert not is_palindrome("hello")
    assert not is_palindrome("")


def test_health_endpoint(client):
    res = client.get("/health")
    assert res.status_code == 200
    assert res.get_json()["status"] == "ok"


def test_add_endpoint(client):
    res = client.get("/api/add?a=2&b=3")
    assert res.get_json()["result"] == 5


def test_add_endpoint_bad_input(client):
    assert client.get("/api/add?a=x&b=3").status_code == 400
