#!/usr/bin/env python3
"""
Simple Flask application for CI/CD pipeline demonstration.
"""

from flask import Flask, jsonify, request
from datetime import datetime
import os

app = Flask(__name__)

# Application configuration
app.config['JSON_SORT_KEYS'] = False
VERSION = os.environ.get('APP_VERSION', '1.0.0')
ENVIRONMENT = os.environ.get('ENVIRONMENT', 'development')


class AppConfig:
    """Application configuration."""

    def __init__(self):
        self.version = VERSION
        self.environment = ENVIRONMENT
        self.started_at = datetime.now().isoformat()


config = AppConfig()


@app.route('/', methods=['GET'])
def index():
    """Root endpoint."""
    return jsonify({
        'message': 'Welcome to CI/CD Demo App',
        'version': config.version,
        'environment': config.environment,
        'timestamp': datetime.now().isoformat(),
    })


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint."""
    return jsonify({
        'status': 'healthy',
        'version': config.version,
        'uptime': (datetime.now() - datetime.fromisoformat(config.started_at)).total_seconds(),
    }), 200


@app.route('/api/info', methods=['GET'])
def info():
    """Get application information."""
    return jsonify({
        'name': 'CI/CD Demo Application',
        'version': config.version,
        'environment': config.environment,
        'python_version': '3.11',
        'started_at': config.started_at,
    })


@app.route('/api/echo', methods=['POST'])
def echo():
    """Echo endpoint for testing."""
    data = request.get_json() or {}
    return jsonify({
        'echo': data,
        'timestamp': datetime.now().isoformat(),
    })


@app.route('/api/calculate', methods=['POST'])
def calculate():
    """Simple calculator endpoint."""
    data = request.get_json() or {}

    try:
        a = float(data.get('a', 0))
        b = float(data.get('b', 0))
        operation = data.get('operation', 'add')

        if operation == 'add':
            result = a + b
        elif operation == 'subtract':
            result = a - b
        elif operation == 'multiply':
            result = a * b
        elif operation == 'divide':
            if b == 0:
                return jsonify({'error': 'Division by zero'}), 400
            result = a / b
        else:
            return jsonify({'error': f'Unknown operation: {operation}'}), 400

        return jsonify({
            'a': a,
            'b': b,
            'operation': operation,
            'result': result,
        })

    except (ValueError, TypeError) as e:
        return jsonify({'error': f'Invalid input: {str(e)}'}), 400


@app.route('/api/status', methods=['GET'])
def status():
    """Get application status."""
    return jsonify({
        'status': 'running',
        'version': config.version,
        'environment': config.environment,
        'timestamp': datetime.now().isoformat(),
        'checks': {
            'database': 'connected',
            'cache': 'connected',
            'external_api': 'reachable',
        },
    })


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors."""
    return jsonify({
        'error': 'Not found',
        'message': str(error),
    }), 404


@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors."""
    return jsonify({
        'error': 'Internal server error',
        'message': str(error),
    }), 500


if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8000))
    debug = ENVIRONMENT == 'development'
    app.run(host='0.0.0.0', port=port, debug=debug)
