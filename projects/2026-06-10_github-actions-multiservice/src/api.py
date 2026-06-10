"""Simple Flask API for demonstration."""
from flask import Flask, jsonify
import os

app = Flask(__name__)

__version__ = "1.0.0"


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint."""
    return jsonify({
        'status': 'healthy',
        'version': __version__,
        'environment': os.getenv('ENVIRONMENT', 'development')
    }), 200


@app.route('/api/v1/ping', methods=['GET'])
def ping():
    """Simple ping endpoint."""
    return jsonify({'message': 'pong'}), 200


@app.route('/api/v1/info', methods=['GET'])
def info():
    """API info endpoint."""
    return jsonify({
        'name': 'Multiservice API',
        'version': __version__,
        'status': 'running'
    }), 200


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors."""
    return jsonify({'error': 'Not found'}), 404


@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors."""
    return jsonify({'error': 'Internal server error'}), 500


if __name__ == '__main__':
    debug = os.getenv('FLASK_ENV') == 'development'
    app.run(host='0.0.0.0', port=5000, debug=debug)
