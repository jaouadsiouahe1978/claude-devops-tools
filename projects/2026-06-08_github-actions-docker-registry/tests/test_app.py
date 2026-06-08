"""Unit tests for Flask application."""
import pytest
import json


def test_health_endpoint(client):
    """Test the health check endpoint."""
    response = client.get('/')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['status'] == 'healthy'
    assert 'timestamp' in data
    assert 'version' in data


def test_hello_endpoint_default(client):
    """Test hello endpoint with default name."""
    response = client.get('/api/hello')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert 'Hello, World!' in data['message']


def test_hello_endpoint_custom_name(client):
    """Test hello endpoint with custom name."""
    response = client.get('/api/hello?name=DevOps')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert 'Hello, DevOps!' in data['message']


def test_hello_endpoint_invalid_name(client):
    """Test hello endpoint with invalid name."""
    long_name = 'x' * 200
    response = client.get(f'/api/hello?name={long_name}')
    assert response.status_code == 400
    data = json.loads(response.data)
    assert 'error' in data


def test_info_endpoint(client):
    """Test info endpoint."""
    response = client.get('/api/info')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['app_name'] == 'DevOps Flask App'
    assert 'version' in data
    assert 'environment' in data


def test_multiply_valid(client):
    """Test multiply endpoint with valid input."""
    response = client.post('/api/multiply',
                          json={'a': 5, 'b': 3},
                          content_type='application/json')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['result'] == 15


def test_multiply_floats(client):
    """Test multiply with float values."""
    response = client.post('/api/multiply',
                          json={'a': 2.5, 'b': 4.0},
                          content_type='application/json')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['result'] == 10.0


def test_multiply_missing_param(client):
    """Test multiply with missing parameter."""
    response = client.post('/api/multiply',
                          json={'a': 5},
                          content_type='application/json')
    assert response.status_code == 400
    data = json.loads(response.data)
    assert 'error' in data


def test_multiply_invalid_type(client):
    """Test multiply with invalid parameter type."""
    response = client.post('/api/multiply',
                          json={'a': 'five', 'b': 3},
                          content_type='application/json')
    assert response.status_code == 400
    data = json.loads(response.data)
    assert 'error' in data


def test_multiply_no_json(client):
    """Test multiply with no JSON body."""
    response = client.post('/api/multiply')
    assert response.status_code == 400


def test_404_not_found(client):
    """Test 404 error handling."""
    response = client.get('/api/nonexistent')
    assert response.status_code == 404
    data = json.loads(response.data)
    assert 'error' in data


def test_hello_post_method(client):
    """Test POST method on hello endpoint."""
    response = client.post('/api/hello?name=Test')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert 'Hello, Test!' in data['message']


class TestHealthCheck:
    """Group tests for health endpoints."""

    def test_response_has_timestamp(self, client):
        """Test that health response includes timestamp."""
        response = client.get('/')
        data = json.loads(response.data)
        assert 'timestamp' in data
        assert 'T' in data['timestamp']  # ISO format includes T

    def test_response_has_version(self, client):
        """Test that health response includes version."""
        response = client.get('/')
        data = json.loads(response.data)
        assert 'version' in data
        assert isinstance(data['version'], str)
