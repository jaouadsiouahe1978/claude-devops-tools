from flask import Flask, jsonify, request
import os
from datetime import datetime

app = Flask(__name__)

# Configuration from environment variables
ENVIRONMENT = os.getenv('ENVIRONMENT', 'development')
APP_VERSION = os.getenv('APP_VERSION', '1.0.0')
HOSTNAME = os.getenv('HOSTNAME', 'unknown')

@app.route('/')
def home():
    """Main endpoint"""
    return jsonify({
        'message': 'Hello from Kubernetes!',
        'environment': ENVIRONMENT,
        'version': APP_VERSION,
        'hostname': HOSTNAME,
        'timestamp': datetime.utcnow().isoformat()
    })

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'timestamp': datetime.utcnow().isoformat()}), 200

@app.route('/info')
def info():
    """Application info"""
    return jsonify({
        'app': 'DevOps Training App',
        'version': APP_VERSION,
        'environment': ENVIRONMENT,
        'pod_name': HOSTNAME
    })

if __name__ == '__main__':
    debug_mode = ENVIRONMENT == 'development'
    app.run(host='0.0.0.0', port=5000, debug=debug_mode)
