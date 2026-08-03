#!/usr/bin/env python3

from flask import Flask, jsonify
from prometheus_client import Counter, Histogram, generate_latest, REGISTRY
import random
import time

app = Flask(__name__)

# Métriques Prometheus
request_count = Counter('app_requests_total', 'Total requests', ['method', 'endpoint', 'status'])
request_duration = Histogram('app_request_duration_seconds', 'Request duration', ['endpoint'])
errors_total = Counter('app_errors_total', 'Total errors', ['error_type'])
app_info = Counter('app_info', 'Application info', ['version', 'environment'])

# Enregistrer l'info de l'app
app_info.labels(version='1.0.0', environment='development').inc()

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

@app.route('/metrics')
def metrics():
    return generate_latest(REGISTRY), 200, {'Content-Type': 'text/plain; charset=utf-8'}

@app.route('/api/data')
def get_data():
    start = time.time()

    # Simuler une opération
    time.sleep(random.uniform(0.1, 0.5))

    # Compteur de requête
    request_count.labels(method='GET', endpoint='/api/data', status=200).inc()

    # Durée de la requête
    duration = time.time() - start
    request_duration.labels(endpoint='/api/data').observe(duration)

    return jsonify({
        'message': 'Sample data',
        'timestamp': time.time(),
        'data': [random.randint(1, 100) for _ in range(5)]
    }), 200

@app.route('/api/error')
def trigger_error():
    try:
        # Simuler une erreur aléatoire
        if random.random() < 0.3:
            raise Exception("Random error simulated")
        request_count.labels(method='GET', endpoint='/api/error', status=200).inc()
        return jsonify({'message': 'Success'}), 200
    except Exception as e:
        errors_total.labels(error_type='application').inc()
        request_count.labels(method='GET', endpoint='/api/error', status=500).inc()
        return jsonify({'error': str(e)}), 500

@app.route('/ping')
def ping():
    request_count.labels(method='GET', endpoint='/ping', status=200).inc()
    return 'pong', 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=False)
