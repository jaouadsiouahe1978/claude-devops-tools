from flask import Flask, jsonify
from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST
import time
import random
from datetime import datetime

app = Flask(__name__)

# Prometheus metrics
http_requests_total = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

http_request_duration_seconds = Histogram(
    'http_request_duration_seconds',
    'HTTP request latency',
    ['method', 'endpoint']
)

app_info = Counter(
    'app_info',
    'Application info',
    ['version', 'environment']
)

temperature = Gauge(
    'server_temperature_celsius',
    'Simulated server temperature'
)

cpu_usage = Gauge(
    'cpu_usage_percent',
    'Simulated CPU usage'
)

@app.route('/')
def index():
    start_time = time.time()
    data = {
        'status': 'ok',
        'timestamp': datetime.utcnow().isoformat(),
        'message': 'DevOps Monitoring Stack - Sample App'
    }

    duration = time.time() - start_time
    http_requests_total.labels(method='GET', endpoint='/', status='200').inc()
    http_request_duration_seconds.labels(method='GET', endpoint='/').observe(duration)

    return jsonify(data), 200

@app.route('/api/data')
def api_data():
    start_time = time.time()

    data = {
        'temperature': round(20 + random.uniform(-5, 10), 2),
        'cpu_usage': round(random.uniform(10, 90), 2),
        'memory_usage': round(random.uniform(30, 80), 2),
        'requests_count': random.randint(100, 1000)
    }

    temperature.set(data['temperature'])
    cpu_usage.set(data['cpu_usage'])

    duration = time.time() - start_time
    http_requests_total.labels(method='GET', endpoint='/api/data', status='200').inc()
    http_request_duration_seconds.labels(method='GET', endpoint='/api/data').observe(duration)

    return jsonify(data), 200

@app.route('/metrics')
def metrics():
    app_info.labels(version='1.0', environment='production').inc()
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

@app.errorhandler(404)
def not_found(error):
    http_requests_total.labels(method='GET', endpoint='unknown', status='404').inc()
    return jsonify({'error': 'Not found'}), 404

if __name__ == '__main__':
    app_info.labels(version='1.0', environment='production').inc()
    app.run(host='0.0.0.0', port=8080, debug=False)
