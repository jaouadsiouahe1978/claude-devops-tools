#!/usr/bin/env python3
"""
Unit tests for the CI/CD demo application.
"""

import pytest
import json
from src.app import app


@pytest.fixture
def client():
    """Create a test client for the Flask application."""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


class TestHealthEndpoint:
    """Test health check endpoint."""

    def test_health_check_returns_200(self, client):
        """Test that health check returns 200 status code."""
        response = client.get('/health')
        assert response.status_code == 200

    def test_health_check_returns_json(self, client):
        """Test that health check returns valid JSON."""
        response = client.get('/health')
        data = json.loads(response.data)
        assert data['status'] == 'healthy'

    def test_health_check_has_version(self, client):
        """Test that health check includes version."""
        response = client.get('/health')
        data = json.loads(response.data)
        assert 'version' in data


class TestIndexEndpoint:
    """Test index endpoint."""

    def test_index_returns_200(self, client):
        """Test that index returns 200 status code."""
        response = client.get('/')
        assert response.status_code == 200

    def test_index_returns_json(self, client):
        """Test that index returns valid JSON."""
        response = client.get('/')
        data = json.loads(response.data)
        assert 'message' in data
        assert 'version' in data


class TestInfoEndpoint:
    """Test info endpoint."""

    def test_info_returns_200(self, client):
        """Test that info returns 200 status code."""
        response = client.get('/api/info')
        assert response.status_code == 200

    def test_info_returns_complete_data(self, client):
        """Test that info returns complete data."""
        response = client.get('/api/info')
        data = json.loads(response.data)
        assert 'name' in data
        assert 'version' in data
        assert 'environment' in data
        assert data['name'] == 'CI/CD Demo Application'


class TestEchoEndpoint:
    """Test echo endpoint."""

    def test_echo_with_json_data(self, client):
        """Test echo endpoint with JSON data."""
        payload = {'test': 'data', 'number': 42}
        response = client.post('/api/echo', json=payload)
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data['echo'] == payload

    def test_echo_empty_request(self, client):
        """Test echo endpoint with empty request."""
        response = client.post('/api/echo')
        assert response.status_code == 200


class TestCalculateEndpoint:
    """Test calculator endpoint."""

    def test_calculate_add(self, client):
        """Test addition operation."""
        payload = {'a': 5, 'b': 3, 'operation': 'add'}
        response = client.post('/api/calculate', json=payload)
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data['result'] == 8

    def test_calculate_subtract(self, client):
        """Test subtraction operation."""
        payload = {'a': 10, 'b': 3, 'operation': 'subtract'}
        response = client.post('/api/calculate', json=payload)
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data['result'] == 7

    def test_calculate_multiply(self, client):
        """Test multiplication operation."""
        payload = {'a': 4, 'b': 5, 'operation': 'multiply'}
        response = client.post('/api/calculate', json=payload)
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data['result'] == 20

    def test_calculate_divide(self, client):
        """Test division operation."""
        payload = {'a': 10, 'b': 2, 'operation': 'divide'}
        response = client.post('/api/calculate', json=payload)
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data['result'] == 5.0

    def test_calculate_divide_by_zero(self, client):
        """Test division by zero error handling."""
        payload = {'a': 10, 'b': 0, 'operation': 'divide'}
        response = client.post('/api/calculate', json=payload)
        assert response.status_code == 400
        data = json.loads(response.data)
        assert 'error' in data

    def test_calculate_invalid_operation(self, client):
        """Test invalid operation error handling."""
        payload = {'a': 5, 'b': 3, 'operation': 'power'}
        response = client.post('/api/calculate', json=payload)
        assert response.status_code == 400

    def test_calculate_default_values(self, client):
        """Test calculator with default values."""
        payload = {'operation': 'add'}
        response = client.post('/api/calculate', json=payload)
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data['result'] == 0


class TestStatusEndpoint:
    """Test status endpoint."""

    def test_status_returns_200(self, client):
        """Test that status returns 200 status code."""
        response = client.get('/api/status')
        assert response.status_code == 200

    def test_status_shows_running(self, client):
        """Test that status shows running."""
        response = client.get('/api/status')
        data = json.loads(response.data)
        assert data['status'] == 'running'

    def test_status_includes_checks(self, client):
        """Test that status includes health checks."""
        response = client.get('/api/status')
        data = json.loads(response.data)
        assert 'checks' in data
        assert 'database' in data['checks']


class TestErrorHandling:
    """Test error handling."""

    def test_404_not_found(self, client):
        """Test 404 error handling."""
        response = client.get('/api/nonexistent')
        assert response.status_code == 404
        data = json.loads(response.data)
        assert 'error' in data

    def test_method_not_allowed(self, client):
        """Test method not allowed."""
        response = client.get('/api/echo')  # Should be POST
        assert response.status_code == 405


class TestIntegration:
    """Integration tests."""

    def test_full_workflow(self, client):
        """Test a full workflow."""
        # 1. Check health
        response = client.get('/health')
        assert response.status_code == 200

        # 2. Get info
        response = client.get('/api/info')
        assert response.status_code == 200

        # 3. Calculate
        response = client.post('/api/calculate', json={'a': 10, 'b': 5, 'operation': 'add'})
        assert response.status_code == 200

        # 4. Check status
        response = client.get('/api/status')
        assert response.status_code == 200


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
