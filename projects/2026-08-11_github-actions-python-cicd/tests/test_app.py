"""
Test suite for Flask application.
Tests all endpoints and error handling.
"""

import json
import pytest


class TestHealthCheck:
    """Test health check endpoint."""

    def test_health_check_returns_200(self, client):
        """Test that health check returns 200."""
        response = client.get('/health')
        assert response.status_code == 200

    def test_health_check_returns_healthy_status(self, client):
        """Test that health check returns healthy status."""
        response = client.get('/health')
        data = json.loads(response.data)
        assert data['status'] == 'healthy'

    def test_health_check_has_timestamp(self, client):
        """Test that health check includes timestamp."""
        response = client.get('/health')
        data = json.loads(response.data)
        assert 'timestamp' in data

    def test_health_check_has_service_name(self, client):
        """Test that health check includes service name."""
        response = client.get('/health')
        data = json.loads(response.data)
        assert data['service'] == 'python-cicd-demo'


class TestHelloEndpoint:
    """Test hello endpoint."""

    def test_hello_without_name(self, client):
        """Test hello endpoint without name parameter."""
        response = client.get('/api/hello')
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data['message'] == 'Hello, World!'

    def test_hello_with_name(self, client):
        """Test hello endpoint with name parameter."""
        response = client.get('/api/hello?name=Jaouad')
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data['message'] == 'Hello, Jaouad!'

    def test_hello_with_special_characters(self, client):
        """Test hello endpoint with special characters."""
        response = client.get('/api/hello?name=Jean-Pierre')
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data['message'] == 'Hello, Jean-Pierre!'

    def test_hello_returns_timestamp(self, client):
        """Test that hello endpoint returns timestamp."""
        response = client.get('/api/hello')
        data = json.loads(response.data)
        assert 'timestamp' in data

    def test_hello_with_invalid_name_type(self, client):
        """Test hello endpoint with invalid name type."""
        # This is a basic test - in a real app you might test more edge cases
        response = client.get('/api/hello?name=ValidName')
        assert response.status_code == 200


class TestInfoEndpoint:
    """Test info endpoint."""

    def test_info_returns_200(self, client):
        """Test that info endpoint returns 200."""
        response = client.get('/api/info')
        assert response.status_code == 200

    def test_info_includes_app_name(self, client):
        """Test that info includes app name."""
        response = client.get('/api/info')
        data = json.loads(response.data)
        assert data['app_name'] == 'Python CI/CD Demo'

    def test_info_includes_version(self, client):
        """Test that info includes version."""
        response = client.get('/api/info')
        data = json.loads(response.data)
        assert data['version'] == '1.0.0'

    def test_info_includes_environment(self, client):
        """Test that info includes environment."""
        response = client.get('/api/info')
        data = json.loads(response.data)
        assert 'environment' in data

    def test_info_includes_python_version(self, client):
        """Test that info includes Python version."""
        response = client.get('/api/info')
        data = json.loads(response.data)
        assert 'python_version' in data


class TestEchoEndpoint:
    """Test echo endpoint."""

    def test_echo_valid_json(self, client):
        """Test echo endpoint with valid JSON."""
        payload = {'message': 'test', 'value': 42}
        response = client.post(
            '/api/echo',
            data=json.dumps(payload),
            content_type='application/json'
        )
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data['echo'] == payload

    def test_echo_empty_json(self, client):
        """Test echo endpoint with empty JSON."""
        response = client.post(
            '/api/echo',
            data=json.dumps({}),
            content_type='application/json'
        )
        assert response.status_code == 200

    def test_echo_no_json(self, client):
        """Test echo endpoint without JSON."""
        response = client.post('/api/echo')
        assert response.status_code == 400
        data = json.loads(response.data)
        assert 'error' in data

    def test_echo_includes_received_at(self, client):
        """Test that echo includes received_at timestamp."""
        payload = {'test': 'data'}
        response = client.post(
            '/api/echo',
            data=json.dumps(payload),
            content_type='application/json'
        )
        data = json.loads(response.data)
        assert 'received_at' in data

    def test_echo_with_complex_json(self, client):
        """Test echo with complex JSON structure."""
        payload = {
            'user': 'jaouad',
            'scores': [1, 2, 3, 4, 5],
            'nested': {'key': 'value'}
        }
        response = client.post(
            '/api/echo',
            data=json.dumps(payload),
            content_type='application/json'
        )
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data['echo'] == payload


class TestErrorHandling:
    """Test error handling."""

    def test_404_not_found(self, client):
        """Test 404 error handling."""
        response = client.get('/nonexistent')
        assert response.status_code == 404
        data = json.loads(response.data)
        assert data['error'] == 'Not Found'

    def test_404_includes_method(self, client):
        """Test that 404 includes HTTP method."""
        response = client.get('/api/nonexistent')
        data = json.loads(response.data)
        assert data['method'] == 'GET'

    def test_404_includes_path(self, client):
        """Test that 404 includes request path."""
        response = client.get('/api/nonexistent')
        data = json.loads(response.data)
        assert '/api/nonexistent' in data['path']


class TestMethods:
    """Test HTTP methods."""

    def test_health_get_only(self, client):
        """Test that health endpoint only accepts GET."""
        response = client.post('/health')
        assert response.status_code == 405  # Method Not Allowed

    def test_hello_get_only(self, client):
        """Test that hello endpoint only accepts GET."""
        response = client.post('/api/hello')
        assert response.status_code == 405

    def test_echo_post_only(self, client):
        """Test that echo endpoint only accepts POST."""
        response = client.get('/api/echo')
        assert response.status_code == 405


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
