#!/usr/bin/env python3
"""
Simple Flask application for Kubernetes autoscaling testing.
Provides endpoints for health checks and CPU-intensive operations.
"""

from flask import Flask, jsonify
import time
import os
from datetime import datetime

app = Flask(__name__)

# Get hostname to identify which pod is responding
HOSTNAME = os.getenv('HOSTNAME', 'unknown')


@app.route('/', methods=['GET'])
def health():
    """Health check endpoint for Kubernetes liveness probe."""
    return jsonify({
        'status': 'healthy',
        'hostname': HOSTNAME,
        'timestamp': datetime.utcnow().isoformat()
    }), 200


@app.route('/ready', methods=['GET'])
def ready():
    """Readiness probe endpoint."""
    return jsonify({
        'status': 'ready',
        'hostname': HOSTNAME,
        'timestamp': datetime.utcnow().isoformat()
    }), 200


@app.route('/cpu-intensive', methods=['GET'])
def cpu_intensive():
    """CPU-intensive endpoint to trigger autoscaling."""
    start = time.time()

    # Perform CPU-intensive calculation
    result = 0
    for i in range(50_000_000):
        result += i ** 2

    duration = time.time() - start

    return jsonify({
        'status': 'completed',
        'hostname': HOSTNAME,
        'duration_seconds': round(duration, 2),
        'result': result,
        'timestamp': datetime.utcnow().isoformat()
    }), 200


@app.route('/memory-test', methods=['GET'])
def memory_test():
    """Memory-intensive endpoint (allocates ~100MB)."""
    size_mb = 100
    data = bytearray(size_mb * 1024 * 1024)

    return jsonify({
        'status': 'allocated',
        'hostname': HOSTNAME,
        'memory_mb': size_mb,
        'timestamp': datetime.utcnow().isoformat()
    }), 200


@app.route('/info', methods=['GET'])
def info():
    """System information endpoint."""
    return jsonify({
        'hostname': HOSTNAME,
        'app_name': 'devops-autoscaling-app',
        'version': '1.0.0',
        'environment': os.getenv('ENVIRONMENT', 'unknown'),
        'timestamp': datetime.utcnow().isoformat()
    }), 200


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors."""
    return jsonify({
        'error': 'Not found',
        'message': 'The requested endpoint does not exist',
        'hostname': HOSTNAME
    }), 404


@app.errorhandler(500)
def server_error(error):
    """Handle 500 errors."""
    return jsonify({
        'error': 'Internal server error',
        'message': str(error),
        'hostname': HOSTNAME
    }), 500


if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
