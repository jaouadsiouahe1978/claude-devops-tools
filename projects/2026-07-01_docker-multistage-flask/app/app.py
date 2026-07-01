#!/usr/bin/env python3
"""
Flask Application - DevOps Demo
Démontre une app multi-tier avec Flask + PostgreSQL
"""

from flask import Flask, jsonify, request
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
import os
import logging
from datetime import datetime

# Configuration
app = Flask(__name__)

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Database configuration
DATABASE_URL = os.getenv(
    'DATABASE_URL',
    'postgresql://appuser:apppassword123@localhost:5432/flaskapp'
)

try:
    engine = create_engine(DATABASE_URL, echo=False)
    Session = sessionmaker(bind=engine)
    logger.info(f"✅ Database connection pool created")
except Exception as e:
    logger.error(f"❌ Failed to create database engine: {e}")
    engine = None


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint - no DB needed"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'service': 'flask-app'
    }), 200


@app.route('/db-test', methods=['GET'])
def db_test():
    """Test database connectivity"""
    if not engine:
        return jsonify({
            'status': 'error',
            'message': 'Database engine not initialized'
        }), 500

    try:
        with engine.connect() as connection:
            result = connection.execute(text("SELECT COUNT(*) as user_count FROM users;"))
            row = result.fetchone()
            user_count = row[0] if row else 0

        return jsonify({
            'status': 'success',
            'message': 'Database connection successful',
            'users_count': user_count,
            'timestamp': datetime.utcnow().isoformat()
        }), 200
    except Exception as e:
        logger.error(f"Database error: {e}")
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500


@app.route('/users', methods=['GET'])
def get_users():
    """Get all users from database"""
    if not engine:
        return jsonify({'error': 'Database not available'}), 503

    try:
        with engine.connect() as connection:
            result = connection.execute(text("SELECT id, username, email, created_at FROM users ORDER BY id;"))
            users = []
            for row in result:
                users.append({
                    'id': row[0],
                    'username': row[1],
                    'email': row[2],
                    'created_at': row[3].isoformat() if row[3] else None
                })

        return jsonify({
            'status': 'success',
            'count': len(users),
            'users': users
        }), 200
    except Exception as e:
        logger.error(f"Error fetching users: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/users', methods=['POST'])
def create_user():
    """Create a new user"""
    if not engine:
        return jsonify({'error': 'Database not available'}), 503

    data = request.get_json()
    if not data or 'username' not in data or 'email' not in data:
        return jsonify({'error': 'Missing username or email'}), 400

    try:
        with engine.connect() as connection:
            connection.execute(
                text(
                    "INSERT INTO users (username, email) VALUES (:username, :email);"
                ),
                {'username': data['username'], 'email': data['email']}
            )
            connection.commit()

        return jsonify({
            'status': 'success',
            'message': f"User '{data['username']}' created successfully"
        }), 201
    except Exception as e:
        logger.error(f"Error creating user: {e}")
        return jsonify({'error': str(e)}), 400


@app.route('/info', methods=['GET'])
def app_info():
    """Application info"""
    return jsonify({
        'app': 'Flask Multi-stage Docker Demo',
        'version': '1.0.0',
        'environment': os.getenv('FLASK_ENV', 'production'),
        'database': 'PostgreSQL 15',
        'docker': 'Multi-stage build',
        'endpoints': [
            '/health - Health check',
            '/db-test - Test DB connectivity',
            '/users - List users (GET) or create (POST)',
            '/info - This info'
        ]
    }), 200


@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not found', 'message': 'Endpoint does not exist'}), 404


@app.errorhandler(500)
def server_error(error):
    return jsonify({'error': 'Server error', 'message': 'Internal server error'}), 500


if __name__ == '__main__':
    logger.info("🚀 Starting Flask application on 0.0.0.0:5000")
    app.run(host='0.0.0.0', port=5000, debug=True)
