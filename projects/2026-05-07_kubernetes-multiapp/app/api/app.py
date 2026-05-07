#!/usr/bin/env python3
from flask import Flask, jsonify, request
from datetime import datetime
import os
import logging

app = Flask(__name__)

# Configuration depuis l'environnement
LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
FLASK_ENV = os.getenv('FLASK_ENV', 'development')

# Setup logging
logging.basicConfig(level=LOG_LEVEL)
logger = logging.getLogger(__name__)

# Métriques simples
request_count = 0
error_count = 0


@app.route('/api/status', methods=['GET'])
def status():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'environment': FLASK_ENV,
        'timestamp': datetime.utcnow().isoformat()
    }), 200


@app.route('/api/info', methods=['GET'])
def info():
    """Info endpoint"""
    return jsonify({
        'service': 'API Backend',
        'version': '1.0',
        'environment': FLASK_ENV,
        'hostname': os.getenv('HOSTNAME', 'unknown'),
        'timestamp': datetime.utcnow().isoformat()
    }), 200


@app.route('/api/data', methods=['GET'])
def get_data():
    """Sample data endpoint"""
    global request_count
    request_count += 1

    return jsonify({
        'message': 'This is sample API data',
        'request_count': request_count,
        'timestamp': datetime.utcnow().isoformat(),
        'data': [
            {'id': 1, 'name': 'Item 1', 'value': 100},
            {'id': 2, 'name': 'Item 2', 'value': 200},
            {'id': 3, 'name': 'Item 3', 'value': 300}
        ]
    }), 200


@app.route('/api/metrics', methods=['GET'])
def metrics():
    """Simple metrics endpoint"""
    return jsonify({
        'requests': request_count,
        'errors': error_count,
        'uptime_seconds': 0
    }), 200


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    global error_count
    error_count += 1
    return jsonify({'error': 'Not found', 'message': 'Endpoint not found'}), 404


@app.errorhandler(500)
def server_error(error):
    """Handle 500 errors"""
    global error_count
    error_count += 1
    logger.error(f'Server error: {error}')
    return jsonify({'error': 'Internal server error'}), 500


if __name__ == '__main__':
    logger.info(f'Starting API server in {FLASK_ENV} mode')
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=(FLASK_ENV == 'development')
    )
