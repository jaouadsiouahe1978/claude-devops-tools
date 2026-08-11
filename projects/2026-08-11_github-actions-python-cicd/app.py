"""
Flask application with health checks and API endpoints.
Demonstrates best practices for Python web applications.
"""

import logging
import os
from datetime import datetime

from flask import Flask, jsonify, request

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize Flask app
app = Flask(__name__)

# Configuration
app.config['ENV'] = os.getenv('FLASK_ENV', 'production')
app.config['DEBUG'] = app.config['ENV'] == 'development'


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint for monitoring."""
    logger.info('Health check requested')
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'service': 'python-cicd-demo'
    }), 200


@app.route('/api/hello', methods=['GET'])
def hello():
    """Simple greeting endpoint."""
    name = request.args.get('name', 'World')

    if not name or not isinstance(name, str):
        return jsonify({'error': 'Invalid name parameter'}), 400

    logger.info(f'Hello endpoint called with name: {name}')
    return jsonify({
        'message': f'Hello, {name}!',
        'timestamp': datetime.utcnow().isoformat()
    }), 200


@app.route('/api/info', methods=['GET'])
def info():
    """Return application info."""
    logger.info('Info endpoint requested')
    return jsonify({
        'app_name': 'Python CI/CD Demo',
        'version': '1.0.0',
        'environment': app.config['ENV'],
        'python_version': os.sys.version,
        'timestamp': datetime.utcnow().isoformat()
    }), 200


@app.route('/api/echo', methods=['POST'])
def echo():
    """Echo back JSON data."""
    try:
        data = request.get_json()

        if not data:
            return jsonify({'error': 'No JSON data provided'}), 400

        logger.info(f'Echo endpoint called with data: {data}')
        return jsonify({
            'echo': data,
            'received_at': datetime.utcnow().isoformat()
        }), 200

    except Exception as e:
        logger.error(f'Error in echo endpoint: {str(e)}')
        return jsonify({'error': 'Failed to process request'}), 500


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors."""
    logger.warning(f'404 error: {request.path}')
    return jsonify({
        'error': 'Not Found',
        'path': request.path,
        'method': request.method
    }), 404


@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors."""
    logger.error(f'500 error: {str(error)}')
    return jsonify({
        'error': 'Internal Server Error',
        'message': 'An unexpected error occurred'
    }), 500


@app.before_request
def log_request():
    """Log incoming requests."""
    logger.debug(f'{request.method} {request.path}')


if __name__ == '__main__':
    app.run(
        host='0.0.0.0',
        port=int(os.getenv('PORT', 5000)),
        debug=app.config['DEBUG']
    )
