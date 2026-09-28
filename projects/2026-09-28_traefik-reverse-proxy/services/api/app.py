#!/usr/bin/env python
"""
Simple Flask API for testing Traefik reverse proxy
"""
from flask import Flask, jsonify, request
from datetime import datetime
import os

app = Flask(__name__)

# Sample data
services = {
    "traefik": {"name": "Traefik Reverse Proxy", "status": "running"},
    "web1": {"name": "Web Service 1 (Nginx)", "status": "running"},
    "web2": {"name": "Web Service 2 (Apache)", "status": "running"},
    "api": {"name": "API Service (Flask)", "status": "running"},
}

@app.route('/', methods=['GET'])
def home():
    """Home endpoint"""
    return jsonify({
        "service": "API Service",
        "status": "running",
        "timestamp": datetime.utcnow().isoformat(),
        "message": "This is a simple API routed through Traefik"
    })

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat()
    }), 200

@app.route('/api/services', methods=['GET'])
def get_services():
    """Get all services"""
    return jsonify({
        "services": services,
        "count": len(services),
        "timestamp": datetime.utcnow().isoformat()
    })

@app.route('/api/services/<service_name>', methods=['GET'])
def get_service(service_name):
    """Get a specific service"""
    if service_name in services:
        return jsonify({
            "name": service_name,
            "data": services[service_name],
            "timestamp": datetime.utcnow().isoformat()
        })
    else:
        return jsonify({
            "error": f"Service '{service_name}' not found"
        }), 404

@app.route('/api/request-info', methods=['GET'])
def request_info():
    """Get information about the current request"""
    return jsonify({
        "method": request.method,
        "host": request.host,
        "remote_addr": request.remote_addr,
        "user_agent": request.user_agent.string,
        "headers": dict(request.headers),
        "timestamp": datetime.utcnow().isoformat()
    })

@app.route('/api/echo', methods=['POST', 'GET'])
def echo():
    """Echo endpoint to test data transmission"""
    if request.method == 'POST':
        data = request.get_json() or {}
    else:
        data = request.args.to_dict()

    return jsonify({
        "received": data,
        "timestamp": datetime.utcnow().isoformat()
    })

@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({
        "error": "Not Found",
        "message": "The requested endpoint does not exist",
        "timestamp": datetime.utcnow().isoformat()
    }), 404

@app.errorhandler(500)
def server_error(error):
    """Handle 500 errors"""
    return jsonify({
        "error": "Internal Server Error",
        "message": str(error),
        "timestamp": datetime.utcnow().isoformat()
    }), 500

if __name__ == '__main__':
    # Run Flask development server
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=os.getenv('FLASK_ENV') == 'development'
    )
