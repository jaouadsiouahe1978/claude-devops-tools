#!/usr/bin/env python3
"""
Flask application with Prometheus metrics
Demonstrates how to instrument a Python app with prometheus_client
"""

from flask import Flask, jsonify, request
from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST
import time
import random
import os

app = Flask(__name__)

# Metrics
REQUEST_COUNT = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

REQUEST_DURATION = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration in seconds',
    ['method', 'endpoint']
)

ACTIVE_REQUESTS = Gauge(
    'http_active_requests',
    'Currently active HTTP requests'
)

PROCESSED_ITEMS = Counter(
    'processed_items_total',
    'Total items processed',
    ['status']
)

# Custom application metric
APP_INFO = Gauge(
    'app_info',
    'Application information',
    ['version', 'environment']
)
APP_INFO.labels(version='1.0.0', environment='docker').set(1)


@app.before_request
def before_request():
    request.start_time = time.time()
    ACTIVE_REQUESTS.inc()


@app.after_request
def after_request(response):
    ACTIVE_REQUESTS.dec()

    if hasattr(request, 'start_time'):
        duration = time.time() - request.start_time
        REQUEST_DURATION.labels(
            method=request.method,
            endpoint=request.endpoint or 'unknown'
        ).observe(duration)

    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.endpoint or 'unknown',
        status=response.status_code
    ).inc()

    return response


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify(status='healthy'), 200


@app.route('/metrics', methods=['GET'])
def metrics():
    """Prometheus metrics endpoint"""
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}


@app.route('/api/v1/data', methods=['GET'])
def get_data():
    """Get some data - simulates processing"""
    # Simulate some work
    time.sleep(random.uniform(0.1, 0.5))

    data = {
        'timestamp': int(time.time()),
        'value': random.randint(1, 100),
        'status': 'success'
    }

    PROCESSED_ITEMS.labels(status='success').inc()
    return jsonify(data), 200


@app.route('/api/v1/slow', methods=['GET'])
def slow_endpoint():
    """Slow endpoint for testing high latency alerts"""
    delay = random.uniform(0.5, 2.0)
    time.sleep(delay)
    return jsonify(delay=delay), 200


@app.route('/api/v1/error', methods=['GET'])
def error_endpoint():
    """Endpoint that sometimes returns errors"""
    if random.random() < 0.3:  # 30% error rate
        PROCESSED_ITEMS.labels(status='error').inc()
        return jsonify(error='Random error'), 500

    PROCESSED_ITEMS.labels(status='success').inc()
    return jsonify(status='success'), 200


@app.route('/api/v1/compute', methods=['POST'])
def compute():
    """Compute endpoint"""
    try:
        data = request.get_json()
        value = data.get('value', 0)

        # Simulate some computation
        time.sleep(random.uniform(0.1, 0.3))

        result = value * 2
        PROCESSED_ITEMS.labels(status='success').inc()

        return jsonify(input=value, result=result), 200
    except Exception as e:
        PROCESSED_ITEMS.labels(status='error').inc()
        return jsonify(error=str(e)), 400


@app.route('/', methods=['GET'])
def index():
    """Index page with API documentation"""
    return jsonify(
        message='DevOps Monitoring Demo App',
        version='1.0.0',
        endpoints={
            '/health': 'Health check',
            '/metrics': 'Prometheus metrics',
            '/api/v1/data': 'Get data',
            '/api/v1/slow': 'Slow endpoint (tests latency)',
            '/api/v1/error': 'Error endpoint (30% error rate)',
            '/api/v1/compute': 'POST endpoint for computation'
        }
    ), 200


@app.errorhandler(404)
def not_found(error):
    return jsonify(error='Not found'), 404


@app.errorhandler(500)
def internal_error(error):
    return jsonify(error='Internal server error'), 500


if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=False)
