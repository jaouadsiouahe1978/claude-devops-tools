#!/usr/bin/env python3
"""
Application Flask avec instrumentation Prometheus
Expose des métriques custom : requêtes HTTP, erreurs, latence, etc.
"""

from flask import Flask, jsonify
from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST
import time
import random
import os

app = Flask(__name__)

# Métriques Prometheus
http_requests_total = Counter(
    'http_requests_total',
    'Nombre total de requêtes HTTP',
    ['method', 'endpoint', 'status']
)

http_request_duration_seconds = Histogram(
    'http_request_duration_seconds',
    'Durée des requêtes HTTP',
    ['method', 'endpoint']
)

app_errors_total = Counter(
    'app_errors_total',
    'Nombre total d\'erreurs applicatives',
    ['type']
)

active_connections = Gauge(
    'active_connections',
    'Nombre de connexions actives'
)

@app.before_request
def before_request():
    """Initialiser le chronomètre avant chaque requête"""
    import flask
    flask.g.start_time = time.time()
    active_connections.inc()

@app.after_request
def after_request(response):
    """Enregistrer les métriques après chaque requête"""
    import flask
    duration = time.time() - flask.g.start_time

    http_request_duration_seconds.labels(
        method=flask.request.method,
        endpoint=flask.request.endpoint or 'unknown'
    ).observe(duration)

    http_requests_total.labels(
        method=flask.request.method,
        endpoint=flask.request.endpoint or 'unknown',
        status=response.status_code
    ).inc()

    active_connections.dec()
    return response

@app.route('/')
def index():
    """Page d'accueil"""
    return jsonify({
        'message': 'DevOps Monitoring Stack - Application Flask',
        'status': 'running',
        'version': '1.0.0',
        'endpoints': [
            '/ (root)',
            '/api/data',
            '/api/users',
            '/health',
            '/metrics (Prometheus)'
        ]
    })

@app.route('/api/data')
def get_data():
    """Endpoint qui simule une opération"""
    # Simuler une latence variable
    delay = random.uniform(0.1, 0.5)
    time.sleep(delay)

    return jsonify({
        'data': ['item1', 'item2', 'item3'],
        'count': 3,
        'timestamp': time.time()
    })

@app.route('/api/users')
def get_users():
    """Endpoint utilisateurs"""
    # Simuler une erreur aléatoire (10% de chance)
    if random.random() < 0.1:
        app_errors_total.labels(type='user_fetch_error').inc()
        return jsonify({'error': 'Failed to fetch users'}), 500

    return jsonify({
        'users': [
            {'id': 1, 'name': 'Alice'},
            {'id': 2, 'name': 'Bob'},
            {'id': 3, 'name': 'Charlie'}
        ]
    })

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': time.time()
    }), 200

@app.route('/metrics')
def metrics():
    """Endpoint Prometheus - exporte toutes les métriques"""
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

@app.errorhandler(404)
def not_found(error):
    """Gérer les 404"""
    app_errors_total.labels(type='not_found').inc()
    return jsonify({'error': 'Not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    """Gérer les 500"""
    app_errors_total.labels(type='internal_error').inc()
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
