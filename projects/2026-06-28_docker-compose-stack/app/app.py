#!/usr/bin/env python3
"""
Simple Flask REST API for task management
Connected to PostgreSQL database and Redis cache
"""

import os
import json
from datetime import datetime
from dotenv import load_dotenv
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
import redis

# Load environment variables
load_dotenv()

# Flask app configuration
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv(
    'DATABASE_URL',
    'postgresql://devops:devops123@postgres:5432/tasks_db'
)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialize database
db = SQLAlchemy(app)

# Initialize Redis
redis_client = redis.Redis(
    host=os.getenv('REDIS_HOST', 'redis'),
    port=int(os.getenv('REDIS_PORT', 6379)),
    decode_responses=True
)

# Database Models
class Task(db.Model):
    __tablename__ = 'tasks'

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text)
    status = db.Column(db.String(50), default='pending')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'status': self.status,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

# Routes
@app.route('/api/health', methods=['GET'])
def health():
    """Health check endpoint"""
    try:
        # Check database connection
        db.session.execute(db.text('SELECT 1'))
        # Check Redis connection
        redis_client.ping()
        return jsonify({
            'status': 'healthy',
            'timestamp': datetime.utcnow().isoformat(),
            'database': 'connected',
            'redis': 'connected'
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'error': str(e)
        }), 500

@app.route('/api/tasks', methods=['GET'])
def get_tasks():
    """Get all tasks (with caching)"""
    # Try to get from cache
    cache_key = 'tasks_all'
    cached = redis_client.get(cache_key)

    if cached:
        return jsonify(json.loads(cached)), 200

    # Fetch from database
    tasks = Task.query.all()
    tasks_data = [task.to_dict() for task in tasks]

    # Cache for 60 seconds
    redis_client.setex(cache_key, 60, json.dumps(tasks_data))

    return jsonify(tasks_data), 200

@app.route('/api/tasks/<int:task_id>', methods=['GET'])
def get_task(task_id):
    """Get a specific task"""
    cache_key = f'task_{task_id}'
    cached = redis_client.get(cache_key)

    if cached:
        return jsonify(json.loads(cached)), 200

    task = Task.query.get(task_id)
    if not task:
        return jsonify({'error': 'Task not found'}), 404

    task_data = task.to_dict()
    redis_client.setex(cache_key, 60, json.dumps(task_data))

    return jsonify(task_data), 200

@app.route('/api/tasks', methods=['POST'])
def create_task():
    """Create a new task"""
    data = request.get_json()

    if not data or 'title' not in data:
        return jsonify({'error': 'Title is required'}), 400

    task = Task(
        title=data['title'],
        description=data.get('description', ''),
        status=data.get('status', 'pending')
    )

    db.session.add(task)
    db.session.commit()

    # Invalidate cache
    redis_client.delete('tasks_all')

    return jsonify(task.to_dict()), 201

@app.route('/api/tasks/<int:task_id>', methods=['PUT'])
def update_task(task_id):
    """Update a task"""
    task = Task.query.get(task_id)
    if not task:
        return jsonify({'error': 'Task not found'}), 404

    data = request.get_json()

    if 'title' in data:
        task.title = data['title']
    if 'description' in data:
        task.description = data['description']
    if 'status' in data:
        task.status = data['status']

    task.updated_at = datetime.utcnow()
    db.session.commit()

    # Invalidate cache
    redis_client.delete(f'task_{task_id}')
    redis_client.delete('tasks_all')

    return jsonify(task.to_dict()), 200

@app.route('/api/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    """Delete a task"""
    task = Task.query.get(task_id)
    if not task:
        return jsonify({'error': 'Task not found'}), 404

    db.session.delete(task)
    db.session.commit()

    # Invalidate cache
    redis_client.delete(f'task_{task_id}')
    redis_client.delete('tasks_all')

    return jsonify({'message': 'Task deleted'}), 200

@app.route('/api/stats', methods=['GET'])
def get_stats():
    """Get statistics about tasks"""
    try:
        total = Task.query.count()
        completed = Task.query.filter_by(status='completed').count()
        in_progress = Task.query.filter_by(status='in_progress').count()
        pending = Task.query.filter_by(status='pending').count()

        stats = {
            'total_tasks': total,
            'completed': completed,
            'in_progress': in_progress,
            'pending': pending,
            'completion_rate': f"{(completed/total*100):.1f}%" if total > 0 else "0%"
        }

        return jsonify(stats), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Endpoint not found'}), 404

@app.errorhandler(500)
def server_error(error):
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    # Create tables if they don't exist
    with app.app_context():
        db.create_all()

    # Run Flask app
    app.run(host='0.0.0.0', port=5000, debug=True)
