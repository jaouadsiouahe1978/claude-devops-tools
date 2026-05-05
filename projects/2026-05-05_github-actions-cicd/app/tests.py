"""Tests for Flask app"""
import pytest
from app import app


@pytest.fixture
def client():
    """Create test client"""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


def test_home(client):
    """Test home endpoint"""
    response = client.get('/')
    assert response.status_code == 200
    assert response.json['status'] == 'healthy'


def test_hello_success(client):
    """Test greeting with valid name"""
    response = client.get('/api/hello/Alice')
    assert response.status_code == 200
    assert 'Alice' in response.json['greeting']
    assert response.json['length'] == 5


def test_hello_invalid(client):
    """Test greeting with invalid name"""
    response = client.get('/api/hello/A')
    assert response.status_code == 400
    assert 'error' in response.json


def test_calculate(client):
    """Test calculate endpoint"""
    response = client.get('/api/calculate')
    assert response.status_code == 200
    assert response.json['sum'] == 8
    assert response.json['product'] == 15
