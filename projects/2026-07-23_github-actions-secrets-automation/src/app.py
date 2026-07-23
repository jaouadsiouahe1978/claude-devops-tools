#!/usr/bin/env python3
import os
from flask import Flask, jsonify

app = Flask(__name__)
ENVIRONMENT = os.getenv('ENVIRONMENT', 'development')

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok', 'environment': ENVIRONMENT}), 200

@app.route('/metrics', methods=['GET'])
def metrics():
    return jsonify({'uptime': 'n/a', 'requests': 42}), 200

@app.route('/api/v1/status', methods=['GET'])
def status():
    return jsonify({
        'application': 'DevOps Demo',
        'environment': ENVIRONMENT,
        'version': '1.0.0'
    }), 200

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not Found', 'status': 404}), 404

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
