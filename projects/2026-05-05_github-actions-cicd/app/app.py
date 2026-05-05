"""Simple Flask API for demonstration"""
from flask import Flask, jsonify

app = Flask(__name__)


@app.route('/', methods=['GET'])
def home():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'message': 'Welcome to CI/CD demo app!'
    }), 200


@app.route('/api/hello/<name>', methods=['GET'])
def hello(name):
    """Greet a user"""
    if not name or len(name) < 2:
        return jsonify({'error': 'Name must be at least 2 characters'}), 400

    return jsonify({
        'greeting': f'Hello, {name}!',
        'length': len(name)
    }), 200


@app.route('/api/calculate', methods=['GET'])
def calculate():
    """Simple math endpoint"""
    a, b = 5, 3
    return jsonify({
        'a': a,
        'b': b,
        'sum': a + b,
        'product': a * b
    }), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
