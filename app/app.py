from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from Flask on AWS EKS 🚀"

@app.route("/health")
def health():
    return {"status": "ok"}, 200

if __name__ == "__main__":
    # For local testing only; in container we use Gunicorn
    app.run(host="0.0.0.0", port=5000)
