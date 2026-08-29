#!/usr/bin/env python3
from flask import Flask, request, jsonify
from datetime import datetime
import os
import socket

app = Flask(__name__)

SERVICE_NAME = os.getenv('SERVICE_NAME', 'Service')
SERVICE_PORT = int(os.getenv('SERVICE_PORT', 5000))
SERVICE_COLOR = os.getenv('SERVICE_COLOR', 'gray')
HOSTNAME = socket.gethostname()
CONTAINER_ID = HOSTNAME[:12]

@app.route('/', methods=['GET'])
def index():
    return jsonify({
        'status': 'healthy',
        'service': SERVICE_NAME,
        'container_id': CONTAINER_ID,
        'hostname': HOSTNAME,
        'color': SERVICE_COLOR,
        'timestamp': datetime.utcnow().isoformat()
    }), 200

@app.route('/api/info', methods=['GET'])
def info():
    return jsonify({
        'name': SERVICE_NAME,
        'port': SERVICE_PORT,
        'color': SERVICE_COLOR,
        'container_id': CONTAINER_ID,
        'hostname': HOSTNAME,
        'timestamp': datetime.utcnow().isoformat()
    }), 200

@app.route('/api/health', methods=['GET'])
def health():
    return jsonify({
        'status': 'ok',
        'service': SERVICE_NAME
    }), 200

@app.errorhandler(404)
def not_found(error):
    return jsonify({
        'error': 'Not Found',
        'service': SERVICE_NAME
    }), 404

if __name__ == '__main__':
    print(f"Starting {SERVICE_NAME} on port {SERVICE_PORT}")
    app.run(host='0.0.0.0', port=SERVICE_PORT, debug=False, threaded=True)
