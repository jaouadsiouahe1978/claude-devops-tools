import pytest
from unittest.mock import patch


def add(a, b):
    """Simple addition function for demo"""
    return a + b


def subtract(a, b):
    """Simple subtraction function for demo"""
    return a - b


def multiply(a, b):
    """Simple multiplication function for demo"""
    return a * b


def divide(a, b):
    """Simple division function for demo"""
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b


class TestMath:
    """Math operation tests"""

    def test_add_positive(self):
        assert add(2, 3) == 5

    def test_add_negative(self):
        assert add(-1, 1) == 0

    def test_add_zero(self):
        assert add(0, 0) == 0

    def test_subtract(self):
        assert subtract(5, 3) == 2

    def test_multiply(self):
        assert multiply(4, 5) == 20

    def test_divide(self):
        assert divide(10, 2) == 5.0

    def test_divide_by_zero(self):
        with pytest.raises(ValueError):
            divide(10, 0)


class TestEnvironment:
    """Test environment variable handling"""

    @patch.dict('os.environ', {'API_KEY': 'test-key', 'ENV': 'test'})
    def test_env_variables(self):
        import os
        assert os.environ.get('API_KEY') == 'test-key'
        assert os.environ.get('ENV') == 'test'


def test_matrix_support():
    """Verify tests run on multiple Python versions"""
    import sys
    assert sys.version_info >= (3, 9)


@pytest.fixture
def sample_data():
    """Provide sample test data"""
    return {'value': 42, 'name': 'test'}


def test_with_fixture(sample_data):
    """Test using fixtures"""
    assert sample_data['value'] == 42
    assert sample_data['name'] == 'test'
