#!/usr/bin/env python3
"""
Simple Flask app for Kubernetes Helm deployment demo.
Environment variables control behavior (dev/staging/prod).
"""

import os
import logging
from flask import Flask, jsonify
from datetime import datetime

app = Flask(__name__)

# Configuration from environment variables
ENV = os.getenv('ENV', 'dev')
APP_NAME = os.getenv('APP_NAME', 'MyApp')
LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
DEBUG_MODE = os.getenv('DEBUG', 'false').lower() == 'true'
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '5432')
FEATURE_FLAG = os.getenv('FEATURE_FLAG', 'disabled')

# Setup logging
logging.basicConfig(
    level=getattr(logging, LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

logger.info(f"Starting {APP_NAME} in {ENV} environment")
logger.info(f"Debug mode: {DEBUG_MODE}, DB: {DB_HOST}:{DB_PORT}")


@app.route('/', methods=['GET'])
def index():
    """Health check endpoint."""
    return jsonify({
        'status': 'healthy',
        'app_name': APP_NAME,
        'environment': ENV,
        'timestamp': datetime.utcnow().isoformat()
    }), 200


@app.route('/health', methods=['GET'])
def health():
    """Kubernetes liveness/readiness probe."""
    return jsonify({'alive': True}), 200


@app.route('/config', methods=['GET'])
def config():
    """Show current configuration."""
    config_data = {
        'app_name': APP_NAME,
        'environment': ENV,
        'debug': DEBUG_MODE,
        'database': {
            'host': DB_HOST,
            'port': DB_PORT
        },
        'feature_flag': FEATURE_FLAG,
        'log_level': LOG_LEVEL
    }

    # Hide DB password in logs
    logger.info(f"Config endpoint hit: env={ENV}, app={APP_NAME}")

    return jsonify(config_data), 200


@app.route('/info', methods=['GET'])
def info():
    """Application info endpoint."""
    return jsonify({
        'version': '1.0.0',
        'name': APP_NAME,
        'environment': ENV,
        'features': {
            'new_feature': FEATURE_FLAG == 'enabled',
            'debug_endpoints': DEBUG_MODE
        },
        'started_at': datetime.utcnow().isoformat()
    }), 200


@app.route('/api/data', methods=['GET'])
def get_data():
    """Dummy API endpoint."""
    data = {
        'items': [
            {'id': 1, 'name': 'Item 1', 'env': ENV},
            {'id': 2, 'name': 'Item 2', 'env': ENV},
            {'id': 3, 'name': 'Item 3', 'env': ENV}
        ],
        'count': 3
    }
    return jsonify(data), 200


@app.route('/error', methods=['GET'])
def error_endpoint():
    """Testing endpoint that simulates an error."""
    logger.error("Error endpoint was called")
    return jsonify({'error': 'Simulated error in ' + ENV}), 500


@app.errorhandler(404)
def not_found(e):
    """Handle 404 errors."""
    return jsonify({'error': 'Not found'}), 404


@app.errorhandler(500)
def server_error(e):
    """Handle 500 errors."""
    logger.exception("Internal server error")
    return jsonify({'error': 'Internal server error'}), 500


if __name__ == '__main__':
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=DEBUG_MODE
    )
