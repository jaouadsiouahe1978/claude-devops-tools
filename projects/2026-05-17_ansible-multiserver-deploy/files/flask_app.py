#!/usr/bin/env python3
"""
Application Flask simple pour demo Ansible
Peut se connecter à PostgreSQL si configuré
"""

from flask import Flask, jsonify
import os
import socket

app = Flask(__name__)

@app.route('/')
def index():
    hostname = socket.gethostname()
    return jsonify({
        'message': 'Hello from Flask!',
        'hostname': hostname,
        'status': 'running'
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

@app.route('/api/info')
def info():
    return jsonify({
        'app_name': 'MyApp',
        'version': '1.0.0',
        'hostname': socket.gethostname(),
        'environment': os.getenv('ENV', 'development')
    })

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000, debug=False)
