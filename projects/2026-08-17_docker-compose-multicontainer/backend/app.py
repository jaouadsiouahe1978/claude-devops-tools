#!/usr/bin/env python3
"""
Flask Backend API for Docker Compose Multi-Container Application
Provides REST endpoints for item management with PostgreSQL persistence
"""

import os
from datetime import datetime
from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
import logging

# Initialize Flask app
app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Database Configuration
database_url = os.getenv('DATABASE_URL', 'postgresql://devops:devops123@postgres:5432/appdb')
app.config['SQLALCHEMY_DATABASE_URI'] = database_url
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['JSON_SORT_KEYS'] = False

# Initialize SQLAlchemy
db = SQLAlchemy(app)


# Database Model
class Item(db.Model):
    """Item model for storing todo/product items"""
    __tablename__ = 'items'

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text)
    status = db.Column(db.String(50), default='pending')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self):
        """Convert model to dictionary"""
        return {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'status': self.status,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }


# Context manager for database initialization
@app.before_request
def before_request():
    """Create tables if they don't exist"""
    try:
        db.create_all()
    except Exception as e:
        logger.warning(f"Could not create tables: {e}")


# Health Check Endpoints
@app.route('/api/health', methods=['GET'])
def health():
    """Simple health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'service': 'flask-backend'
    }), 200


@app.route('/api/ready', methods=['GET'])
def ready():
    """Readiness check - verify database connection"""
    try:
        # Try a simple database query
        db.session.execute(db.text('SELECT 1'))
        return jsonify({
            'status': 'ready',
            'database': 'connected',
            'timestamp': datetime.utcnow().isoformat()
        }), 200
    except Exception as e:
        logger.error(f"Database connection failed: {e}")
        return jsonify({
            'status': 'not_ready',
            'database': 'disconnected',
            'error': str(e)
        }), 503


# REST API Endpoints for Items
@app.route('/api/items', methods=['GET'])
def get_items():
    """Get all items"""
    try:
        items = Item.query.all()
        return jsonify({
            'status': 'success',
            'count': len(items),
            'data': [item.to_dict() for item in items]
        }), 200
    except Exception as e:
        logger.error(f"Error fetching items: {e}")
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/api/items/<int:item_id>', methods=['GET'])
def get_item(item_id):
    """Get a specific item by ID"""
    try:
        item = Item.query.get_or_404(item_id)
        return jsonify({
            'status': 'success',
            'data': item.to_dict()
        }), 200
    except Exception as e:
        logger.error(f"Error fetching item {item_id}: {e}")
        return jsonify({'status': 'error', 'message': str(e)}), 404


@app.route('/api/items', methods=['POST'])
def create_item():
    """Create a new item"""
    try:
        data = request.get_json()

        if not data or 'title' not in data:
            return jsonify({
                'status': 'error',
                'message': 'Missing required field: title'
            }), 400

        item = Item(
            title=data.get('title'),
            description=data.get('description', ''),
            status=data.get('status', 'pending')
        )

        db.session.add(item)
        db.session.commit()

        logger.info(f"Created item {item.id}: {item.title}")
        return jsonify({
            'status': 'success',
            'message': 'Item created',
            'data': item.to_dict()
        }), 201
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error creating item: {e}")
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/api/items/<int:item_id>', methods=['PUT'])
def update_item(item_id):
    """Update an existing item"""
    try:
        item = Item.query.get_or_404(item_id)
        data = request.get_json()

        if 'title' in data:
            item.title = data['title']
        if 'description' in data:
            item.description = data['description']
        if 'status' in data:
            item.status = data['status']

        db.session.commit()

        logger.info(f"Updated item {item_id}")
        return jsonify({
            'status': 'success',
            'message': 'Item updated',
            'data': item.to_dict()
        }), 200
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error updating item {item_id}: {e}")
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/api/items/<int:item_id>', methods=['DELETE'])
def delete_item(item_id):
    """Delete an item"""
    try:
        item = Item.query.get_or_404(item_id)
        db.session.delete(item)
        db.session.commit()

        logger.info(f"Deleted item {item_id}")
        return jsonify({
            'status': 'success',
            'message': 'Item deleted'
        }), 200
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error deleting item {item_id}: {e}")
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/api/stats', methods=['GET'])
def get_stats():
    """Get statistics about items"""
    try:
        total = Item.query.count()
        by_status = db.session.query(
            Item.status,
            db.func.count(Item.id)
        ).group_by(Item.status).all()

        stats = {
            'total_items': total,
            'by_status': {status: count for status, count in by_status}
        }

        return jsonify({
            'status': 'success',
            'data': stats
        }), 200
    except Exception as e:
        logger.error(f"Error fetching stats: {e}")
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/', methods=['GET'])
def root():
    """Root endpoint with API documentation"""
    return jsonify({
        'service': 'Flask Backend API',
        'version': '1.0.0',
        'endpoints': {
            'health': 'GET /api/health - Health check',
            'ready': 'GET /api/ready - Database readiness',
            'items': {
                'list': 'GET /api/items - List all items',
                'create': 'POST /api/items - Create new item',
                'get': 'GET /api/items/<id> - Get specific item',
                'update': 'PUT /api/items/<id> - Update item',
                'delete': 'DELETE /api/items/<id> - Delete item'
            },
            'stats': 'GET /api/stats - Get statistics'
        }
    }), 200


# Error handlers
@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({'status': 'error', 'message': 'Endpoint not found'}), 404


@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    logger.error(f"Internal server error: {error}")
    return jsonify({'status': 'error', 'message': 'Internal server error'}), 500


# Main entry point
if __name__ == '__main__':
    logger.info("Starting Flask Backend API")
    app.run(host='0.0.0.0', port=5000, debug=True)
