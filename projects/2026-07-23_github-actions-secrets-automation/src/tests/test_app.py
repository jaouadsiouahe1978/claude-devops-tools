import pytest
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_health_endpoint(client):
    response = client.get('/health')
    assert response.status_code == 200
    assert response.json['status'] == 'ok'

def test_metrics_endpoint(client):
    response = client.get('/metrics')
    assert response.status_code == 200

def test_status_endpoint(client):
    response = client.get('/api/v1/status')
    assert response.status_code == 200

def test_404_error(client):
    response = client.get('/nonexistent')
    assert response.status_code == 404
