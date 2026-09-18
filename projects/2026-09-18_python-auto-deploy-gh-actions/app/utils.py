"""
Utility functions for the Python app
"""
import re


def greet(name: str) -> str:
    """Greet someone by name"""
    if not name or len(name.strip()) == 0:
        return "Hello, stranger!"
    return f"Hello, {name.strip()}!"


def calculate_sum(numbers: list[int]) -> int:
    """Calculate sum of numbers"""
    if not isinstance(numbers, list):
        raise TypeError("Input must be a list")
    return sum(numbers)


def validate_email(email: str) -> bool:
    """
    Validate email format using regex
    Simple validation for learning purposes
    """
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))


def factorial(n: int) -> int:
    """Calculate factorial of n"""
    if n < 0:
        raise ValueError("n must be non-negative")
    if n == 0 or n == 1:
        return 1
    return n * factorial(n - 1)


def is_even(n: int) -> bool:
    """Check if number is even"""
    return n % 2 == 0


def fibonacci(n: int) -> list[int]:
    """Generate fibonacci sequence up to n terms"""
    if n <= 0:
        return []
    if n == 1:
        return [0]
    fib = [0, 1]
    for i in range(2, n):
        fib.append(fib[i - 1] + fib[i - 2])
    return fib
