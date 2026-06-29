#!/usr/bin/env python3

import os
import logging
from datetime import datetime
from flask import Flask, jsonify, request
from flask_cors import CORS
from prometheus_client import Counter, Histogram, generate_latest

app = Flask(__name__)
CORS(app)

# Logging
logging.basicConfig(
    level=os.getenv('LOG_LEVEL', 'INFO'),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Metrics
request_counter = Counter('app_requests_total', 'Total requests', ['method', 'endpoint', 'status'])
request_duration = Histogram('app_request_duration_seconds', 'Request duration', ['method', 'endpoint'])

# Database connection (simulé)
def get_db_status():
    """Check database connectivity"""
    db_host = os.getenv('DATABASE_HOST', 'localhost')
    db_port = os.getenv('DATABASE_PORT', '5432')
    db_name = os.getenv('DATABASE_NAME', 'myapp_db')

    # En production, vérifier la vraie connexion
    return {
        'host': db_host,
        'port': db_port,
        'database': db_name,
        'status': 'connected'
    }

# Health check endpoints
@app.route('/health/live', methods=['GET'])
def health_live():
    """Liveness probe - pod is running"""
    return jsonify({'status': 'alive', 'timestamp': datetime.utcnow().isoformat()}), 200

@app.route('/health/ready', methods=['GET'])
def health_ready():
    """Readiness probe - pod is ready to handle traffic"""
    db_status = get_db_status()
    return jsonify({
        'status': 'ready',
        'database': db_status['status'],
        'timestamp': datetime.utcnow().isoformat()
    }), 200

# API endpoints
@app.route('/api/status', methods=['GET'])
def api_status():
    """Get application status"""
    db_status = get_db_status()
    return jsonify({
        'service': 'MyApp Backend API',
        'version': '1.0.0',
        'environment': os.getenv('FLASK_ENV', 'production'),
        'database': db_status,
        'timestamp': datetime.utcnow().isoformat()
    }), 200

@app.route('/api/data', methods=['GET'])
def get_data():
    """Get sample data"""
    logger.info('Fetching data')
    data = [
        {'id': 1, 'name': 'Item 1', 'value': 100},
        {'id': 2, 'name': 'Item 2', 'value': 200},
        {'id': 3, 'name': 'Item 3', 'value': 300},
    ]
    return jsonify({'data': data, 'count': len(data)}), 200

@app.route('/api/data', methods=['POST'])
def create_data():
    """Create new data item"""
    payload = request.get_json()
    logger.info(f'Creating data: {payload}')

    if not payload or 'name' not in payload:
        return jsonify({'error': 'Missing name field'}), 400

    new_item = {
        'id': 4,
        'name': payload['name'],
        'value': payload.get('value', 0)
    }
    return jsonify(new_item), 201

@app.route('/api/config', methods=['GET'])
def get_config():
    """Get configuration"""
    config = {
        'app_name': 'MyApp Backend',
        'log_level': os.getenv('LOG_LEVEL', 'INFO'),
        'environment': os.getenv('FLASK_ENV', 'production'),
        'database': {
            'host': os.getenv('DATABASE_HOST', 'localhost'),
            'port': os.getenv('DATABASE_PORT', '5432'),
            'name': os.getenv('DATABASE_NAME', 'myapp_db'),
        }
    }
    return jsonify(config), 200

# Metrics endpoint
@app.route('/metrics', methods=['GET'])
def metrics():
    """Prometheus metrics"""
    return generate_latest(), 200

# Error handlers
@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    logger.error(f'Internal error: {error}')
    return jsonify({'error': 'Internal server error'}), 500

# Before request hook
@app.before_request
def before_request():
    """Log incoming requests"""
    logger.debug(f'{request.method} {request.path}')

# After request hook
@app.after_request
def after_request(response):
    """Log response and update metrics"""
    request_counter.labels(
        method=request.method,
        endpoint=request.path,
        status=response.status_code
    ).inc()
    return response

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
