"""Simple Flask application for CI/CD pipeline demonstration."""
import os
import logging
from flask import Flask, jsonify, request
from datetime import datetime

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@app.route('/', methods=['GET'])
def health():
    """Health check endpoint."""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'version': os.getenv('APP_VERSION', '1.0.0')
    }), 200


@app.route('/api/hello', methods=['GET', 'POST'])
def hello():
    """Greet endpoint."""
    name = request.args.get('name', 'World')

    if not isinstance(name, str) or len(name) > 100:
        return jsonify({'error': 'Invalid name parameter'}), 400

    message = f"Hello, {name}!"
    logger.info(f"Greeting generated for: {name}")

    return jsonify({
        'message': message,
        'timestamp': datetime.utcnow().isoformat()
    }), 200


@app.route('/api/info', methods=['GET'])
def info():
    """Return application info."""
    return jsonify({
        'app_name': 'DevOps Flask App',
        'environment': os.getenv('ENVIRONMENT', 'development'),
        'version': os.getenv('APP_VERSION', '1.0.0'),
        'debug': app.debug
    }), 200


@app.route('/api/multiply', methods=['POST'])
def multiply():
    """Multiply two numbers."""
    data = request.get_json()

    if not data or 'a' not in data or 'b' not in data:
        return jsonify({'error': 'Missing parameters: a, b'}), 400

    try:
        a = float(data['a'])
        b = float(data['b'])
        result = a * b
        return jsonify({'result': result}), 200
    except (TypeError, ValueError):
        return jsonify({'error': 'Parameters must be numbers'}), 400


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors."""
    return jsonify({'error': 'Endpoint not found'}), 404


@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors."""
    logger.error(f"Internal server error: {error}")
    return jsonify({'error': 'Internal server error'}), 500


if __name__ == '__main__':
    app.run(
        host='0.0.0.0',
        port=int(os.getenv('PORT', 5000)),
        debug=os.getenv('FLASK_ENV') == 'development'
    )
