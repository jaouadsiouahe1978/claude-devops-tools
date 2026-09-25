#!/usr/bin/env python3
"""
Flask Backend Application pour tester le load balancing
Chaque instance retourne son ID pour vérifier la distribution
"""

from flask import Flask, jsonify, request
import os
import socket
import logging
import json
from datetime import datetime

app = Flask(__name__)

# Configuration
SERVICE_ID = os.environ.get('SERVICE_ID', 'unknown')
SERVICE_NAME = os.environ.get('SERVICE_NAME', 'backend')
HOSTNAME = socket.gethostname()

# Logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Counters pour tracking
request_count = 0
request_times = []


@app.before_request
def before_request():
    """Enregistrer le temps de début"""
    request.start_time = datetime.now()


@app.after_request
def after_request(response):
    """Log les informations de la requête"""
    global request_count, request_times
    request_count += 1

    if hasattr(request, 'start_time'):
        elapsed = (datetime.now() - request.start_time).total_seconds()
        request_times.append(elapsed)
        if len(request_times) > 100:
            request_times.pop(0)

    logger.info(f"{request.method} {request.path} - {response.status_code}")
    return response


@app.route('/', methods=['GET'])
def home():
    """Route d'accueil"""
    return jsonify({
        "message": f"Welcome to {SERVICE_NAME}",
        "service_id": SERVICE_ID,
        "hostname": HOSTNAME,
        "timestamp": datetime.now().isoformat()
    }), 200


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "service": SERVICE_NAME,
        "timestamp": datetime.now().isoformat()
    }), 200


@app.route('/status', methods=['GET'])
def status():
    """Endpoint pour vérifier le load balancing"""
    return jsonify({
        "service_id": SERVICE_ID,
        "service_name": SERVICE_NAME,
        "hostname": HOSTNAME,
        "request_count": request_count,
        "headers": dict(request.headers),
        "remote_addr": request.remote_addr,
        "x_forwarded_for": request.headers.get('X-Forwarded-For'),
        "timestamp": datetime.now().isoformat()
    }), 200


@app.route('/api/users', methods=['GET'])
def get_users():
    """API endpoint - Get users"""
    users = [
        {
            "id": 1,
            "name": "Alice",
            "email": "alice@example.com",
            "served_by": SERVICE_NAME
        },
        {
            "id": 2,
            "name": "Bob",
            "email": "bob@example.com",
            "served_by": SERVICE_NAME
        },
        {
            "id": 3,
            "name": "Charlie",
            "email": "charlie@example.com",
            "served_by": SERVICE_NAME
        }
    ]
    return jsonify(users), 200


@app.route('/api/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    """API endpoint - Get specific user"""
    users = {
        1: {"id": 1, "name": "Alice", "email": "alice@example.com"},
        2: {"id": 2, "name": "Bob", "email": "bob@example.com"},
        3: {"id": 3, "name": "Charlie", "email": "charlie@example.com"}
    }

    user = users.get(user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404

    user["served_by"] = SERVICE_NAME
    return jsonify(user), 200


@app.route('/api/stats', methods=['GET'])
def get_stats():
    """API endpoint - Get backend statistics"""
    avg_response_time = sum(request_times) / len(request_times) if request_times else 0

    return jsonify({
        "service_id": SERVICE_ID,
        "service_name": SERVICE_NAME,
        "hostname": HOSTNAME,
        "total_requests": request_count,
        "avg_response_time_ms": round(avg_response_time * 1000, 2),
        "min_response_time_ms": round(min(request_times) * 1000, 2) if request_times else 0,
        "max_response_time_ms": round(max(request_times) * 1000, 2) if request_times else 0
    }), 200


@app.route('/api/echo', methods=['POST'])
def echo():
    """API endpoint - Echo POST data"""
    data = request.get_json() or {}

    response = {
        "echo": data,
        "served_by": SERVICE_NAME,
        "timestamp": datetime.now().isoformat()
    }
    return jsonify(response), 200


@app.route('/error', methods=['GET'])
def error_endpoint():
    """Endpoint pour tester error handling"""
    return jsonify({"error": "Internal Server Error"}), 500


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({
        "error": "Not Found",
        "served_by": SERVICE_NAME,
        "timestamp": datetime.now().isoformat()
    }), 404


@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    logger.error(f"Internal error: {error}")
    return jsonify({
        "error": "Internal Server Error",
        "served_by": SERVICE_NAME,
        "timestamp": datetime.now().isoformat()
    }), 500


if __name__ == '__main__':
    logger.info(f"Starting {SERVICE_NAME} (ID: {SERVICE_ID}) on 0.0.0.0:5000")
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=False,
        threaded=True
    )
