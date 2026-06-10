"""Tests for Flask API."""
import pytest
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from src.api import app


@pytest.fixture
def client():
    """Create a test client."""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


def test_health_check(client):
    """Test health check endpoint."""
    response = client.get('/health')
    assert response.status_code == 200
    data = response.get_json()
    assert data['status'] == 'healthy'
    assert 'version' in data


def test_ping_endpoint(client):
    """Test ping endpoint."""
    response = client.get('/api/v1/ping')
    assert response.status_code == 200
    data = response.get_json()
    assert data['message'] == 'pong'


def test_info_endpoint(client):
    """Test info endpoint."""
    response = client.get('/api/v1/info')
    assert response.status_code == 200
    data = response.get_json()
    assert data['name'] == 'Multiservice API'
    assert 'version' in data
    assert data['status'] == 'running'


def test_404_error(client):
    """Test 404 error handling."""
    response = client.get('/nonexistent')
    assert response.status_code == 404
    data = response.get_json()
    assert 'error' in data


def test_response_headers(client):
    """Test response headers."""
    response = client.get('/health')
    assert response.content_type == 'application/json'
