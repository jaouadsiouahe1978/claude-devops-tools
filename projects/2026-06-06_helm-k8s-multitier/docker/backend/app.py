#!/usr/bin/env python3
import os
from flask import Flask, jsonify
import psycopg2
from psycopg2.extras import RealDictCursor
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configuration
DB_HOST = os.getenv('DB_HOST', 'postgres')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_NAME = os.getenv('DB_NAME', 'appdb')
DB_USER = os.getenv('DB_USER', 'postgres')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'postgres')
ENVIRONMENT = os.getenv('ENVIRONMENT', 'development')

def get_db_connection():
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD
        )
        return conn
    except Exception as e:
        logger.error(f"Database connection error: {e}")
        return None

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    conn = get_db_connection()
    db_status = "✅ OK" if conn else "❌ FAILED"
    if conn:
        conn.close()

    return jsonify({
        'status': 'healthy',
        'environment': ENVIRONMENT,
        'database': db_status,
        'service': 'backend-api'
    }), 200

@app.route('/api/status', methods=['GET'])
def api_status():
    """API status with database check"""
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({'error': 'Database connection failed'}), 503

        cursor = conn.cursor(cursor_factory=RealDictCursor)
        cursor.execute("SELECT version();")
        db_info = cursor.fetchone()
        cursor.close()
        conn.close()

        return jsonify({
            'status': 'ok',
            'service': 'backend-api',
            'environment': ENVIRONMENT,
            'database': {
                'status': 'connected',
                'version': db_info['version'] if db_info else 'unknown'
            }
        }), 200
    except Exception as e:
        logger.error(f"Error: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/items', methods=['GET'])
def get_items():
    """Get all items from database"""
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({'error': 'Database unavailable'}), 503

        cursor = conn.cursor(cursor_factory=RealDictCursor)
        cursor.execute("SELECT * FROM items LIMIT 10;")
        items = cursor.fetchall()
        cursor.close()
        conn.close()

        return jsonify({
            'items': items,
            'count': len(items)
        }), 200
    except Exception as e:
        logger.error(f"Error fetching items: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    logger.info(f"Starting API server (Environment: {ENVIRONMENT})")
    logger.info(f"Database: {DB_USER}@{DB_HOST}:{DB_PORT}/{DB_NAME}")
    app.run(host='0.0.0.0', port=8000, debug=False)
