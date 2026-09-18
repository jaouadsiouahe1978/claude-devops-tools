"""
Unit tests for the Python application
Run with: pytest app/test_main.py -v
"""
import pytest
from fastapi.testclient import TestClient
from main import app
from utils import greet, calculate_sum, validate_email, factorial, is_even, fibonacci

client = TestClient(app)


# ===== API Tests =====

def test_read_root():
    """Test root endpoint"""
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_health_check():
    """Test health check endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_greet_endpoint():
    """Test greet endpoint"""
    response = client.get("/greet/Alice")
    assert response.status_code == 200
    assert "Alice" in response.json()["message"]


def test_greet_endpoint_empty():
    """Test greet endpoint with empty name"""
    response = client.get("/greet/ ")
    assert response.status_code == 200


def test_calculate_endpoint():
    """Test calculate endpoint"""
    response = client.post("/calculate", json=[1, 2, 3, 4, 5])
    assert response.status_code == 200
    data = response.json()
    assert data["sum"] == 15
    assert data["average"] == 3.0


def test_calculate_endpoint_empty():
    """Test calculate endpoint with empty list"""
    response = client.post("/calculate", json=[])
    assert response.status_code == 400


def test_validate_email_endpoint():
    """Test email validation endpoint"""
    response = client.post("/validate-email", json={"email": "test@example.com"})
    assert response.status_code == 200
    assert response.json()["valid"] is True


def test_validate_email_endpoint_invalid():
    """Test email validation with invalid email"""
    response = client.post("/validate-email", json={"email": "invalid.email"})
    assert response.status_code == 200
    assert response.json()["valid"] is False


def test_info_endpoint():
    """Test info endpoint"""
    response = client.get("/info")
    assert response.status_code == 200
    data = response.json()
    assert "name" in data
    assert "version" in data
    assert "endpoints" in data


# ===== Utility Function Tests =====

def test_greet_function():
    """Test greet function"""
    assert greet("Alice") == "Hello, Alice!"
    assert greet("") == "Hello, stranger!"
    assert greet("   ") == "Hello, stranger!"


def test_calculate_sum_function():
    """Test calculate_sum function"""
    assert calculate_sum([1, 2, 3]) == 6
    assert calculate_sum([0]) == 0
    assert calculate_sum([-1, 1]) == 0


def test_calculate_sum_invalid_input():
    """Test calculate_sum with invalid input"""
    with pytest.raises(TypeError):
        calculate_sum("not a list")


def test_validate_email_function():
    """Test validate_email function"""
    assert validate_email("test@example.com") is True
    assert validate_email("user.name@domain.co.uk") is True
    assert validate_email("invalid.email") is False
    assert validate_email("@example.com") is False
    assert validate_email("user@") is False


def test_factorial():
    """Test factorial function"""
    assert factorial(0) == 1
    assert factorial(1) == 1
    assert factorial(5) == 120
    assert factorial(10) == 3628800


def test_factorial_negative():
    """Test factorial with negative input"""
    with pytest.raises(ValueError):
        factorial(-1)


def test_is_even():
    """Test is_even function"""
    assert is_even(2) is True
    assert is_even(4) is True
    assert is_even(1) is False
    assert is_even(0) is True
    assert is_even(-2) is True


def test_fibonacci():
    """Test fibonacci function"""
    assert fibonacci(0) == []
    assert fibonacci(1) == [0]
    assert fibonacci(5) == [0, 1, 1, 2, 3]
    assert fibonacci(8) == [0, 1, 1, 2, 3, 5, 8, 13]


def test_fibonacci_negative():
    """Test fibonacci with negative input"""
    assert fibonacci(-5) == []


# ===== Integration Tests =====

def test_workflow_sequence():
    """Test a sequence of operations"""
    # Health check
    health = client.get("/health")
    assert health.status_code == 200

    # Greet
    greet_resp = client.get("/greet/DevOps")
    assert greet_resp.status_code == 200

    # Calculate
    calc_resp = client.post("/calculate", json=[10, 20, 30])
    assert calc_resp.status_code == 200
    assert calc_resp.json()["sum"] == 60


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--cov=app"])
