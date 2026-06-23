#!/usr/bin/env python3
"""
Simple API application for demonstrating Kubernetes/Helm deployment
Connects to PostgreSQL for data persistence and Redis for caching
"""

import os
import json
import logging
from flask import Flask, jsonify
from datetime import datetime
import psycopg2
from redis import Redis

logging.basicConfig(
    level=os.getenv('LOG_LEVEL', 'INFO'),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

def get_db_connection():
    """Get PostgreSQL connection"""
    try:
        conn = psycopg2.connect(
            host=os.getenv('DATABASE_HOST', 'localhost'),
            port=os.getenv('DATABASE_PORT', 5432),
            user=os.getenv('DATABASE_USER', 'postgres'),
            password=os.getenv('DATABASE_PASSWORD', 'postgres'),
            database=os.getenv('DATABASE_NAME', 'devops_db')
        )
        return conn
    except Exception as e:
        logger.error(f"Database connection failed: {e}")
        return None

def get_redis_connection():
    """Get Redis connection"""
    try:
        r = Redis(
            host=os.getenv('REDIS_HOST', 'localhost'),
            port=int(os.getenv('REDIS_PORT', 6379)),
            decode_responses=True
        )
        r.ping()
        return r
    except Exception as e:
        logger.error(f"Redis connection failed: {e}")
        return None

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    db_conn = get_db_connection()
    redis_conn = get_redis_connection()

    db_status = "ok" if db_conn else "failed"
    redis_status = "ok" if redis_conn else "failed"

    status = "healthy" if (db_conn and redis_conn) else "degraded"

    return jsonify({
        'status': status,
        'timestamp': datetime.utcnow().isoformat(),
        'database': db_status,
        'cache': redis_status,
        'version': '1.0.0'
    }), 200

@app.route('/api/status', methods=['GET'])
def status():
    """Application status"""
    return jsonify({
        'app': 'devops-app',
        'version': '1.0.0',
        'environment': os.getenv('LOG_LEVEL', 'INFO'),
        'timestamp': datetime.utcnow().isoformat()
    }), 200

@app.route('/api/info', methods=['GET'])
def info():
    """Application info"""
    return jsonify({
        'name': 'DevOps Multi-Service Application',
        'description': 'Demonstrates Kubernetes + Helm deployment',
        'services': [
            'API (this service)',
            'PostgreSQL Database',
            'Redis Cache'
        ],
        'endpoints': {
            '/health': 'Health check',
            '/api/status': 'Application status',
            '/api/info': 'Application info',
            '/metrics': 'Prometheus metrics'
        }
    }), 200

@app.route('/metrics', methods=['GET'])
def metrics():
    """Prometheus-compatible metrics"""
    return '''# HELP requests_total Total requests
# TYPE requests_total counter
requests_total{endpoint="/health"} 42
requests_total{endpoint="/api/status"} 10

# HELP database_connections Active database connections
# TYPE database_connections gauge
database_connections 2
''', 200

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not Found'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Internal Server Error'}), 500

if __name__ == '__main__':
    logger.info("🚀 Starting DevOps Application...")
    logger.info(f"Database Host: {os.getenv('DATABASE_HOST')}")
    logger.info(f"Redis Host: {os.getenv('REDIS_HOST')}")

    app.run(
        host='0.0.0.0',
        port=int(os.getenv('PORT', 8080)),
        debug=os.getenv('DEBUG', 'False') == 'True'
    )
