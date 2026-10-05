#!/usr/bin/env python3
import os
import mysql.connector
from flask import Flask, jsonify
from datetime import datetime

app = Flask(__name__)

def get_db_connection():
    """Get connection to MySQL database"""
    return mysql.connector.connect(
        host=os.getenv('DB_HOST', 'mysql-service'),
        user=os.getenv('DB_USER', 'root'),
        password=os.getenv('DB_PASSWORD', 'rootpassword'),
        database=os.getenv('DB_NAME', 'appdb')
    )

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({"status": "ok", "timestamp": datetime.now().isoformat()}), 200

@app.route('/api/messages', methods=['GET'])
def get_messages():
    """Get all messages from database"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT id, content, created_at FROM messages ORDER BY created_at DESC LIMIT 10")
        messages = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(messages), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/messages/<int:msg_id>', methods=['GET'])
def get_message(msg_id):
    """Get a specific message"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT id, content, created_at FROM messages WHERE id = %s", (msg_id,))
        message = cursor.fetchone()
        cursor.close()
        conn.close()

        if message:
            return jsonify(message), 200
        return jsonify({"error": "Message not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/info', methods=['GET'])
def info():
    """Application info endpoint"""
    return jsonify({
        "app": "Multi-Tier Kubernetes Demo",
        "version": "1.0",
        "environment": os.getenv('ENVIRONMENT', 'development'),
        "db_host": os.getenv('DB_HOST', 'mysql-service')
    }), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
