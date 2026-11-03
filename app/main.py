import os
from datetime import datetime, timezone

from flask import Flask, jsonify, request

from app.logic import add, is_palindrome

app = Flask(__name__)
VERSION = os.getenv("APP_VERSION", "1.0.0")


@app.route("/")
def index():
    return (
        "<h1>DevOps Midterm App</h1>"
        f"<p>Version: {VERSION}</p>"
        "<ul>"
        "<li><a href='/health'>/health</a></li>"
        "<li><a href='/api/add?a=2&b=3'>/api/add?a=2&amp;b=3</a></li>"
        "<li><a href='/api/palindrome?text=Level'>/api/palindrome?text=Level</a></li>"
        "</ul>"
    )


@app.route("/health")
def health():
    return jsonify(status="ok", version=VERSION,
                   time=datetime.now(timezone.utc).isoformat())


@app.route("/api/add")
def api_add():
    try:
        a = float(request.args.get("a", ""))
        b = float(request.args.get("b", ""))
    except ValueError:
        return jsonify(error="a and b must be numbers"), 400
    return jsonify(result=add(a, b))


@app.route("/api/palindrome")
def api_palindrome():
    text = request.args.get("text", "")
    return jsonify(text=text, palindrome=is_palindrome(text))
