#!/usr/bin/env python3
"""
Simple Flask application that demonstrates ConfigMap and Secret usage in Kubernetes.
Reads configuration from environment variables set by ConfigMaps and Secrets.
"""

import os
from flask import Flask, jsonify
from datetime import datetime

app = Flask(__name__)

def get_config():
    """Load configuration from environment variables."""
    return {
        'app_name': os.getenv('APP_NAME', 'ConfigDemo'),
        'environment': os.getenv('ENVIRONMENT', 'unknown'),
        'version': os.getenv('APP_VERSION', '1.0.0'),
        'log_level': os.getenv('LOG_LEVEL', 'INFO'),
        'database_host': os.getenv('DB_HOST', 'localhost'),
        'database_port': os.getenv('DB_PORT', '5432'),
        'database_name': os.getenv('DB_NAME', 'app'),
        'api_timeout': os.getenv('API_TIMEOUT', '30'),
        'api_key_present': 'yes' if os.getenv('API_KEY') else 'no',
        'db_password_present': 'yes' if os.getenv('DB_PASSWORD') else 'no',
        'timestamp': datetime.now().isoformat()
    }

@app.route('/', methods=['GET'])
def index():
    """Health check endpoint."""
    config = get_config()
    return jsonify({
        'status': 'healthy',
        'message': f"{config['app_name']} running in {config['environment']}",
        'config': config
    })

@app.route('/health', methods=['GET'])
def health():
    """Liveness probe endpoint."""
    return jsonify({'status': 'alive'}), 200

@app.route('/ready', methods=['GET'])
def ready():
    """Readiness probe endpoint."""
    try:
        config = get_config()
        if config['database_host']:
            return jsonify({'status': 'ready'}), 200
        else:
            return jsonify({'status': 'not_ready'}), 503
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 503

@app.route('/config', methods=['GET'])
def show_config():
    """Show current configuration (safe data only, secrets redacted)."""
    config = get_config()
    return jsonify(config)

@app.route('/info', methods=['GET'])
def info():
    """Detailed application info."""
    return jsonify({
        'name': get_config()['app_name'],
        'version': get_config()['version'],
        'environment': get_config()['environment'],
        'database': {
            'host': get_config()['database_host'],
            'port': get_config()['database_port'],
            'name': get_config()['database_name'],
            'password_configured': get_config()['db_password_present']
        },
        'api': {
            'timeout': get_config()['api_timeout'],
            'key_configured': get_config()['api_key_present']
        },
        'logging': {
            'level': get_config()['log_level']
        }
    })

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    debug = os.getenv('DEBUG', 'false').lower() == 'true'
    app.run(host='0.0.0.0', port=port, debug=debug)
