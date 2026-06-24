#!/usr/bin/env python3
"""
Simple Flask API for GitOps demo
"""
import os
import json
from flask import Flask, jsonify
from datetime import datetime

app = Flask(__name__)

# Get version from environment or file
VERSION = os.getenv('APP_VERSION', '1.0.0')
ENVIRONMENT = os.getenv('ENVIRONMENT', 'development')

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'version': VERSION,
        'environment': ENVIRONMENT
    }), 200

@app.route('/version', methods=['GET'])
def version():
    """Get application version"""
    return jsonify({
        'version': VERSION,
        'environment': ENVIRONMENT,
        'build_time': os.getenv('BUILD_TIME', 'unknown')
    }), 200

@app.route('/info', methods=['GET'])
def info():
    """Get application info"""
    return jsonify({
        'name': 'GitOps Demo App',
        'version': VERSION,
        'environment': ENVIRONMENT,
        'pod_name': os.getenv('POD_NAME', 'unknown'),
        'namespace': os.getenv('NAMESPACE', 'default')
    }), 200

@app.route('/', methods=['GET'])
def index():
    """Root endpoint"""
    return jsonify({
        'message': 'Welcome to GitOps Demo App',
        'endpoints': {
            '/health': 'Health check',
            '/version': 'Application version',
            '/info': 'Application info'
        }
    }), 200

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=os.getenv('DEBUG', 'false').lower() == 'true')
