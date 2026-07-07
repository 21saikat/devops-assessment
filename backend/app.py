import logging
import os
from flask import Flask, jsonify
from flask_cors import CORS

# Logging setup - production apps always log properly, not just print()
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# Environment variable diye port/config control kora - hardcode na kora best practice
PORT = int(os.environ.get('PORT', 8080))
APP_VERSION = os.environ.get('APP_VERSION', '1.0.0')


@app.route('/')
def home():
    logger.info("Root endpoint hit")
    return "Application is running"


@app.route('/health')
def health():
    """Kubernetes liveness/readiness probe eijaigay hit korbe"""
    return jsonify({"status": "ok"})


@app.route('/version')
def version():
    """Extra endpoint - deployed version track korar jonno, interview e plus point"""
    return jsonify({"version": APP_VERSION})


@app.errorhandler(404)
def not_found(e):
    return jsonify({"error": "Route not found"}), 404


@app.errorhandler(500)
def server_error(e):
    logger.error(f"Internal server error: {e}")
    return jsonify({"error": "Internal server error"}), 500


if __name__ == '__main__':
    logger.info(f"Starting server on port {PORT}")
    app.run(host='0.0.0.0', port=PORT)
