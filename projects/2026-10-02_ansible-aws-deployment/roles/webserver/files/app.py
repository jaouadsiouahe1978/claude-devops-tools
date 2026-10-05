#!/usr/bin/env python3
"""
Simple Flask Application Example
Deployed with Ansible
"""

from flask import Flask, jsonify, render_template_string
import os
import logging
from datetime import datetime
import socket

app = Flask(__name__)

# Configure logging
logging.basicConfig(level=os.getenv('LOG_LEVEL', 'INFO'))
logger = logging.getLogger(__name__)

@app.route('/')
def index():
    """Home page"""
    html = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Ansible Deployed App</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; }
            .container { background: #f0f0f0; padding: 20px; border-radius: 5px; }
            .info { background: #fff; padding: 10px; margin: 10px 0; border-left: 4px solid #007bff; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 Welcome to Ansible-Deployed Application</h1>
            <div class="info">
                <p><strong>Hostname:</strong> {{ hostname }}</p>
                <p><strong>Timestamp:</strong> {{ timestamp }}</p>
                <p><strong>Version:</strong> {{ version }}</p>
                <p><strong>Environment:</strong> {{ environment }}</p>
            </div>
            <hr>
            <h2>Available Endpoints</h2>
            <ul>
                <li><a href="/health">/health</a> - Health check</li>
                <li><a href="/api/info">/api/info</a> - API information</li>
                <li><a href="/api/stats">/api/stats</a> - System statistics</li>
            </ul>
        </div>
    </body>
    </html>
    """
    return render_template_string(
        html,
        hostname=socket.gethostname(),
        timestamp=datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        version=os.getenv('APP_VERSION', '1.0.0'),
        environment=os.getenv('ENVIRONMENT', 'dev')
    )

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'service': 'webapp'
    }), 200

@app.route('/api/info')
def api_info():
    """API information endpoint"""
    return jsonify({
        'name': 'Ansible Deployed App',
        'version': os.getenv('APP_VERSION', '1.0.0'),
        'environment': os.getenv('ENVIRONMENT', 'dev'),
        'host': socket.gethostname(),
        'timestamp': datetime.now().isoformat()
    }), 200

@app.route('/api/stats')
def api_stats():
    """System statistics endpoint"""
    import psutil
    return jsonify({
        'cpu_percent': psutil.cpu_percent(interval=1),
        'memory_percent': psutil.virtual_memory().percent,
        'disk_percent': psutil.disk_usage('/').percent,
        'timestamp': datetime.now().isoformat()
    }), 200

@app.errorhandler(404)
def not_found(error):
    """404 error handler"""
    return jsonify({'error': 'Not found', 'status': 404}), 404

@app.errorhandler(500)
def server_error(error):
    """500 error handler"""
    logger.error(f"Server error: {error}")
    return jsonify({'error': 'Internal server error', 'status': 500}), 500

if __name__ == '__main__':
    app.run(
        host='0.0.0.0',
        port=int(os.getenv('APP_PORT', 8000)),
        debug=os.getenv('DEBUG', 'False') == 'True'
    )
