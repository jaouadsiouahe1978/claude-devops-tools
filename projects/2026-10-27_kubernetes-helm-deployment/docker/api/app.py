#!/usr/bin/env python3

import os
import json
import logging
from datetime import datetime
from flask import Flask, jsonify, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Configuration
ENV = os.getenv('APP_ENV', 'development')
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_NAME = os.getenv('DB_NAME', 'myapp')
DB_USER = os.getenv('DB_USER', 'myapp')
DB_PASS = os.getenv('DB_PASSWORD', 'password')

# Logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Métriques
request_count = 0
start_time = datetime.now()


@app.before_request
def before_request():
    global request_count
    request_count += 1
    logger.info(f"{request.method} {request.path} from {request.remote_addr}")


@app.route('/health', methods=['GET'])
def health():
    """Health check simple"""
    return jsonify({
        'status': 'ok',
        'timestamp': datetime.now().isoformat()
    }), 200


@app.route('/info', methods=['GET'])
def info():
    """Informations sur l'application"""
    uptime = (datetime.now() - start_time).total_seconds()

    return jsonify({
        'name': 'MyApp API',
        'version': '1.0.0',
        'environment': ENV,
        'uptime_seconds': int(uptime),
        'hostname': os.getenv('HOSTNAME', 'unknown'),
        'pod_name': os.getenv('POD_NAME', 'unknown'),
        'namespace': os.getenv('NAMESPACE', 'default'),
        'requests_handled': request_count,
    }), 200


@app.route('/db-status', methods=['GET'])
def db_status():
    """Vérifier la connexion à la base de données"""
    try:
        import psycopg2

        # Essayer de se connecter
        conn = psycopg2.connect(
            host=DB_HOST,
            port=int(DB_PORT),
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASS,
            connect_timeout=3
        )

        cursor = conn.cursor()
        cursor.execute("SELECT version();")
        version = cursor.fetchone()[0]
        cursor.close()
        conn.close()

        return jsonify({
            'status': 'connected',
            'database': f"PostgreSQL",
            'host': DB_HOST,
            'port': int(DB_PORT),
            'version': version.split(',')[0] if ',' in version else version,
        }), 200

    except Exception as e:
        logger.warning(f"Database connection failed: {str(e)}")
        return jsonify({
            'status': 'disconnected',
            'database': 'PostgreSQL',
            'host': DB_HOST,
            'port': int(DB_PORT),
            'error': str(e),
        }), 503


@app.route('/api/users', methods=['GET'])
def get_users():
    """Liste des utilisateurs (exemple)"""
    try:
        import psycopg2

        conn = psycopg2.connect(
            host=DB_HOST,
            port=int(DB_PORT),
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASS,
            connect_timeout=3
        )

        cursor = conn.cursor()
        cursor.execute("SELECT id, username FROM users LIMIT 10;")
        rows = cursor.fetchall()
        cursor.close()
        conn.close()

        users = [{'id': row[0], 'username': row[1]} for row in rows]

        return jsonify({
            'status': 'success',
            'data': users,
            'count': len(users)
        }), 200

    except Exception as e:
        logger.error(f"Error fetching users: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': str(e),
        }), 500


@app.route('/metrics', methods=['GET'])
def metrics():
    """Métriques Prometheus-like"""
    uptime = (datetime.now() - start_time).total_seconds()

    metrics_text = f"""# HELP app_uptime_seconds Application uptime in seconds
# TYPE app_uptime_seconds gauge
app_uptime_seconds {int(uptime)}

# HELP app_requests_total Total requests handled
# TYPE app_requests_total counter
app_requests_total {request_count}

# HELP app_environment Application environment
# TYPE app_environment gauge
app_environment{{environment="{ENV}"}} 1
"""

    return metrics_text, 200, {'Content-Type': 'text/plain; charset=utf-8'}


@app.route('/', methods=['GET'])
def root():
    """Route racine"""
    return jsonify({
        'message': 'MyApp API Backend',
        'version': '1.0.0',
        'endpoints': {
            'GET /health': 'Health check',
            'GET /info': 'Application info',
            'GET /db-status': 'Database status',
            'GET /api/users': 'List users',
            'GET /metrics': 'Prometheus metrics',
        }
    }), 200


@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not found', 'path': request.path}), 404


@app.errorhandler(500)
def internal_error(error):
    logger.error(f"Internal error: {str(error)}")
    return jsonify({'error': 'Internal server error'}), 500


if __name__ == '__main__':
    logger.info(f"Starting MyApp API in {ENV} environment")
    logger.info(f"Database: {DB_HOST}:{DB_PORT}/{DB_NAME}")

    # En développement
    if ENV == 'development':
        app.run(host='0.0.0.0', port=5000, debug=True)
    else:
        # En production, utiliser gunicorn
        app.run(host='0.0.0.0', port=5000, debug=False)
