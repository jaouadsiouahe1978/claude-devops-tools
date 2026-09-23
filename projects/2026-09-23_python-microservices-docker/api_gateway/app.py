import os
import json
import logging
from flask import Flask, request, jsonify
import requests
from datetime import datetime

app = Flask(__name__)

# Configuration
USER_SERVICE_URL = os.getenv('USER_SERVICE_URL', 'http://user_service:8001')
PRODUCT_SERVICE_URL = os.getenv('PRODUCT_SERVICE_URL', 'http://product_service:8002')
SERVICE_NAME = os.getenv('SERVICE_NAME', 'api-gateway')
LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')

# Logging setup
logging.basicConfig(
    level=getattr(logging, LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(SERVICE_NAME)

@app.before_request
def log_request():
    logger.info(f"{request.method} {request.path} - IP: {request.remote_addr}")

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': SERVICE_NAME,
        'timestamp': datetime.utcnow().isoformat()
    }), 200

@app.route('/', methods=['GET'])
def index():
    """API Gateway welcome page"""
    return jsonify({
        'service': SERVICE_NAME,
        'version': '1.0.0',
        'endpoints': {
            'health': '/health',
            'users': {
                'list': 'GET /users',
                'create': 'POST /users'
            },
            'products': {
                'list': 'GET /products',
                'create': 'POST /products'
            }
        },
        'timestamp': datetime.utcnow().isoformat()
    }), 200

# ============ USER SERVICE ENDPOINTS ============

@app.route('/users', methods=['GET'])
def list_users():
    """List all users - proxy to user service"""
    try:
        response = requests.get(
            f'{USER_SERVICE_URL}/users',
            timeout=5
        )
        logger.info(f"User service response: {response.status_code}")
        return response.json(), response.status_code
    except requests.exceptions.RequestException as e:
        logger.error(f"User service error: {str(e)}")
        return jsonify({'error': 'User service unavailable'}), 503

@app.route('/users', methods=['POST'])
def create_user():
    """Create a new user - proxy to user service"""
    try:
        data = request.get_json()
        response = requests.post(
            f'{USER_SERVICE_URL}/users',
            json=data,
            timeout=5
        )
        logger.info(f"Created user: {data}")
        return response.json(), response.status_code
    except requests.exceptions.RequestException as e:
        logger.error(f"User service error: {str(e)}")
        return jsonify({'error': 'User service unavailable'}), 503

@app.route('/users/<user_id>', methods=['GET'])
def get_user(user_id):
    """Get user by ID - proxy to user service"""
    try:
        response = requests.get(
            f'{USER_SERVICE_URL}/users/{user_id}',
            timeout=5
        )
        return response.json(), response.status_code
    except requests.exceptions.RequestException as e:
        logger.error(f"User service error: {str(e)}")
        return jsonify({'error': 'User service unavailable'}), 503

# ============ PRODUCT SERVICE ENDPOINTS ============

@app.route('/products', methods=['GET'])
def list_products():
    """List all products - proxy to product service"""
    try:
        response = requests.get(
            f'{PRODUCT_SERVICE_URL}/products',
            timeout=5
        )
        logger.info(f"Product service response: {response.status_code}")
        return response.json(), response.status_code
    except requests.exceptions.RequestException as e:
        logger.error(f"Product service error: {str(e)}")
        return jsonify({'error': 'Product service unavailable'}), 503

@app.route('/products', methods=['POST'])
def create_product():
    """Create a new product - proxy to product service"""
    try:
        data = request.get_json()
        response = requests.post(
            f'{PRODUCT_SERVICE_URL}/products',
            json=data,
            timeout=5
        )
        logger.info(f"Created product: {data}")
        return response.json(), response.status_code
    except requests.exceptions.RequestException as e:
        logger.error(f"Product service error: {str(e)}")
        return jsonify({'error': 'Product service unavailable'}), 503

@app.route('/products/<product_id>', methods=['GET'])
def get_product(product_id):
    """Get product by ID - proxy to product service"""
    try:
        response = requests.get(
            f'{PRODUCT_SERVICE_URL}/products/{product_id}',
            timeout=5
        )
        return response.json(), response.status_code
    except requests.exceptions.RequestException as e:
        logger.error(f"Product service error: {str(e)}")
        return jsonify({'error': 'Product service unavailable'}), 503

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Endpoint not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    logger.error(f"Internal server error: {str(error)}")
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    logger.info(f"Starting {SERVICE_NAME} on port 8000")
    app.run(host='0.0.0.0', port=8000, debug=True)
