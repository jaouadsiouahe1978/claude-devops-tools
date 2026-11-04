#!/usr/bin/env python3
"""
Simple Flask application for demonstrating Docker optimization.
"""
import logging
from flask import Flask, jsonify
from datetime import datetime

app = Flask(__name__)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@app.route('/', methods=['GET'])
def health():
    """Health check endpoint."""
    logger.info("Health check requested")
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'service': 'multi-stage-demo'
    }), 200

@app.route('/api/info', methods=['GET'])
def info():
    """Return application info."""
    return jsonify({
        'app': 'Docker Multi-Stage Build Demo',
        'version': '1.0.0',
        'timestamp': datetime.utcnow().isoformat()
    }), 200

@app.route('/api/metrics', methods=['GET'])
def metrics():
    """Return dummy metrics."""
    return jsonify({
        'cpu_usage': 12.5,
        'memory_mb': 64,
        'requests_total': 1234,
        'uptime_seconds': 3600
    }), 200

if __name__ == '__main__':
    logger.info("Starting Flask application")
    app.run(host='0.0.0.0', port=5000, debug=False)
