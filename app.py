from flask import Flask, request
import requests
import os

application = Flask(__name__)


@application.route("/hello")
def hello():
    return "Hello there"


@application.route("/jobs", methods=["POST"])
def jobs():
    token = request.headers["Authorization"]
    data = {"token": token}
    protocol = "http"
    domain = os.getenv("SERVICEB", default="dc-python-app-b")
    port = 5000
    path = "auth"
    url = f"{protocol}://{domain}:{port}/{path}"
    result = requests.post(url, data=data).text
    if result == "density":
        return "Jobs:\nTitle: Devops\nDescription: Awesome\n"
    else:
        return "fail"


if __name__ == "__main__":
    application.run(host="0.0.0.0", port=5000)
