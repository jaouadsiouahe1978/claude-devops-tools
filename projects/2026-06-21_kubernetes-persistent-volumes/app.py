#!/usr/bin/env python3
import os
import json
from datetime import datetime
from flask import Flask, jsonify, request
import psycopg2
from psycopg2.extras import RealDictCursor
import time

app = Flask(__name__)

# Configuration
DB_HOST = os.getenv('POSTGRES_USER', 'postgres')
DB_PORT = 5432
DB_USER = os.getenv('POSTGRES_USER', 'devops_user')
DB_PASS = os.getenv('POSTGRES_PASSWORD', '')
DB_NAME = os.getenv('POSTGRES_DB', 'devops_db')
APP_NAME = os.getenv('APP_NAME', 'DevOps K8s Demo')
APP_VERSION = os.getenv('APP_VERSION', '1.0.0')

def get_db_connection(retries=5, delay=2):
    """Connect to PostgreSQL with retry logic"""
    for attempt in range(retries):
        try:
            conn = psycopg2.connect(
                host="postgres",
                port=DB_PORT,
                user=DB_USER,
                password=DB_PASS,
                database=DB_NAME
            )
            print(f"✓ Database connected successfully")
            return conn
        except psycopg2.OperationalError as e:
            print(f"✗ Connection attempt {attempt + 1}/{retries} failed: {e}")
            if attempt < retries - 1:
                time.sleep(delay)
    raise Exception("Could not connect to database after retries")

def init_db():
    """Initialize database tables"""
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        cur.execute('''
            CREATE TABLE IF NOT EXISTS entries (
                id SERIAL PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                content TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')

        cur.execute('SELECT COUNT(*) FROM entries')
        if cur.fetchone()[0] == 0:
            cur.execute('''
                INSERT INTO entries (title, content) VALUES
                ('Welcome', 'This data persists in PostgreSQL with PersistentVolume'),
                ('Kubernetes', 'Learning StatefulSets and PersistentVolumes'),
                ('DevOps', 'Infrastructure as Code is awesome!')
            ''')

        conn.commit()
        cur.close()
        conn.close()
        print("✓ Database initialized")
    except Exception as e:
        print(f"✗ Database init error: {e}")
        raise

@app.route('/health', methods=['GET'])
def health():
    """Liveness probe endpoint"""
    try:
        conn = get_db_connection()
        conn.close()
        return jsonify({"status": "healthy"}), 200
    except Exception as e:
        return jsonify({"status": "unhealthy", "error": str(e)}), 503

@app.route('/', methods=['GET'])
def home():
    """Root endpoint"""
    return jsonify({
        "app": APP_NAME,
        "version": APP_VERSION,
        "timestamp": datetime.now().isoformat(),
        "endpoints": {
            "GET /": "This endpoint",
            "GET /health": "Health check",
            "GET /api/data": "List all entries",
            "POST /api/data": "Add new entry (JSON: {title, content})",
            "GET /api/data/<id>": "Get entry by ID",
            "PUT /api/data/<id>": "Update entry",
            "DELETE /api/data/<id>": "Delete entry"
        }
    }), 200

@app.route('/api/data', methods=['GET'])
def get_data():
    """Retrieve all entries from database"""
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute('SELECT * FROM entries ORDER BY created_at DESC')
        rows = cur.fetchall()
        cur.close()
        conn.close()

        return jsonify({
            "success": True,
            "count": len(rows),
            "data": [dict(row) for row in rows]
        }), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/data', methods=['POST'])
def create_data():
    """Add new entry to database"""
    try:
        payload = request.get_json()
        if not payload or 'title' not in payload:
            return jsonify({"success": False, "error": "title is required"}), 400

        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            'INSERT INTO entries (title, content) VALUES (%s, %s) RETURNING id',
            (payload.get('title'), payload.get('content', ''))
        )
        entry_id = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({
            "success": True,
            "id": entry_id,
            "message": "Entry created"
        }), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/data/<int:entry_id>', methods=['GET'])
def get_entry(entry_id):
    """Get specific entry"""
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute('SELECT * FROM entries WHERE id = %s', (entry_id,))
        row = cur.fetchone()
        cur.close()
        conn.close()

        if not row:
            return jsonify({"success": False, "error": "Entry not found"}), 404

        return jsonify({
            "success": True,
            "data": dict(row)
        }), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/data/<int:entry_id>', methods=['PUT'])
def update_entry(entry_id):
    """Update entry"""
    try:
        payload = request.get_json()
        conn = get_db_connection()
        cur = conn.cursor()

        updates = []
        values = []
        if 'title' in payload:
            updates.append('title = %s')
            values.append(payload['title'])
        if 'content' in payload:
            updates.append('content = %s')
            values.append(payload['content'])

        if not updates:
            return jsonify({"success": False, "error": "No fields to update"}), 400

        updates.append('updated_at = CURRENT_TIMESTAMP')
        values.append(entry_id)

        query = f'UPDATE entries SET {", ".join(updates)} WHERE id = %s'
        cur.execute(query, values)
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({
            "success": True,
            "message": "Entry updated"
        }), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/data/<int:entry_id>', methods=['DELETE'])
def delete_entry(entry_id):
    """Delete entry"""
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('DELETE FROM entries WHERE id = %s', (entry_id,))
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({
            "success": True,
            "message": "Entry deleted"
        }), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/status', methods=['GET'])
def status():
    """Application status"""
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT COUNT(*) FROM entries')
        entry_count = cur.fetchone()[0]
        cur.close()
        conn.close()

        return jsonify({
            "app_name": APP_NAME,
            "version": APP_VERSION,
            "database": "Connected",
            "entries_count": entry_count,
            "timestamp": datetime.now().isoformat()
        }), 200
    except Exception as e:
        return jsonify({
            "app_name": APP_NAME,
            "version": APP_VERSION,
            "database": "Disconnected",
            "error": str(e),
            "timestamp": datetime.now().isoformat()
        }), 503

if __name__ == '__main__':
    print(f"Starting {APP_NAME} v{APP_VERSION}")
    try:
        init_db()
        app.run(host='0.0.0.0', port=5000, debug=False)
    except Exception as e:
        print(f"✗ Fatal error: {e}")
        exit(1)
