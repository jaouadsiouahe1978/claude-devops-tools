#!/usr/bin/env python3
"""
Application Flask simple pour démonstration DevOps
"""
import os
import psycopg2
from flask import Flask, jsonify
from datetime import datetime

app = Flask(__name__)

def get_db_connection():
    """Connexion à PostgreSQL"""
    try:
        conn = psycopg2.connect(
            host=os.getenv('DB_HOST', 'postgres'),
            database=os.getenv('DB_NAME', 'appdb'),
            user=os.getenv('DB_USER', 'appuser'),
            password=os.getenv('DB_PASSWORD', 'changeme123')
        )
        return conn
    except Exception as e:
        return None

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat()
    }), 200

@app.route('/api/users')
def get_users():
    """Récupérer les utilisateurs depuis PostgreSQL"""
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500

    try:
        cur = conn.cursor()
        cur.execute('SELECT id, username, email FROM users;')
        users = cur.fetchall()
        cur.close()
        conn.close()

        return jsonify({
            'users': [
                {'id': u[0], 'username': u[1], 'email': u[2]}
                for u in users
            ]
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/tasks')
def get_tasks():
    """Récupérer les tâches depuis PostgreSQL"""
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500

    try:
        cur = conn.cursor()
        cur.execute('''
            SELECT id, user_id, title, description, status, created_at
            FROM tasks ORDER BY created_at DESC;
        ''')
        tasks = cur.fetchall()
        cur.close()
        conn.close()

        return jsonify({
            'tasks': [
                {
                    'id': t[0],
                    'user_id': t[1],
                    'title': t[2],
                    'description': t[3],
                    'status': t[4],
                    'created_at': str(t[5])
                }
                for t in tasks
            ]
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/')
def index():
    """Page d'accueil"""
    return jsonify({
        'message': 'DevOps App with Ansible Deployment',
        'version': '1.0.0',
        'endpoints': {
            'health': '/health',
            'users': '/api/users',
            'tasks': '/api/tasks'
        }
    }), 200

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not found'}), 404

if __name__ == '__main__':
    port = int(os.getenv('APP_PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
