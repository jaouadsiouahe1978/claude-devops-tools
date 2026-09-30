import pytest
from app.main import Application


class TestApplication:
    """Test Application class."""

    def test_initialization(self):
        """Test application initialization."""
        config = {
            'version': '0.1.0',
            'name': 'test-app'
        }
        app = Application(config)
        assert app.version == '0.1.0'
        assert app.config['name'] == 'test-app'

    def test_default_initialization(self):
        """Test default initialization."""
        app = Application()
        assert app.version == '0.1.0'
        assert app.config == {}

    def test_validate_config_valid(self):
        """Test valid configuration validation."""
        config = {
            'version': '1.2.3',
            'name': 'myapp'
        }
        app = Application(config)
        assert app.validate_config() is True

    def test_validate_config_missing_name(self):
        """Test validation with missing name."""
        config = {'version': '1.2.3'}
        app = Application(config)
        assert app.validate_config() is False

    def test_validate_config_missing_version(self):
        """Test validation with missing version."""
        config = {'name': 'myapp'}
        app = Application(config)
        assert app.validate_config() is False

    def test_validate_config_invalid_version(self):
        """Test validation with invalid version."""
        config = {
            'version': 'invalid',
            'name': 'myapp'
        }
        app = Application(config)
        assert app.validate_config() is False

    def test_get_status(self):
        """Test get_status method."""
        config = {
            'version': '0.1.0',
            'name': 'test-app'
        }
        app = Application(config)
        status = app.get_status()

        assert status['status'] == 'running'
        assert status['version'] == '0.1.0'
        assert status['config'] == config

    def test_process_user_valid(self):
        """Test processing valid user."""
        app = Application()
        result = app.process_user('user@example.com', 'John Doe')

        assert result['success'] is True
        assert result['email'] == 'user@example.com'
        assert result['name'] == 'John Doe'

    def test_process_user_invalid_email(self):
        """Test processing user with invalid email."""
        app = Application()
        result = app.process_user('invalid-email', 'John Doe')

        assert result['success'] is False
        assert 'error' in result
        assert 'Invalid email format' in result['error']


class TestApplicationIntegration:
    """Integration tests."""

    def test_full_workflow(self):
        """Test complete workflow."""
        config = {
            'version': '1.0.0',
            'name': 'integration-test'
        }
        app = Application(config)

        # Validate config
        assert app.validate_config() is True

        # Get status
        status = app.get_status()
        assert status['status'] == 'running'

        # Process user
        result = app.process_user('dev@example.com', 'Developer')
        assert result['success'] is True
