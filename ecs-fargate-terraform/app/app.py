import os
import socket

from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/")
def index():
    return jsonify(
        message="Hello from ECS Fargate",
        version=os.getenv("APP_VERSION", "v1"),
        host=socket.gethostname(),
    )


@app.get("/health")
def health():
    return "ok", 200


@app.get("/burn")
def burn():
    """Optional CPU load generator for testing auto scaling."""
    total = 0
    for i in range(3_000_000):
        total += i * i
    return jsonify(result=total)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
