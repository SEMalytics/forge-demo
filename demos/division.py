"""
Division by Zero Vulnerability Demo

This file demonstrates missing input validation
where division by zero is not handled.

Forge will detect this and add proper validation.
"""


def add(a, b):
    """Add two numbers."""
    return a + b


def subtract(a, b):
    """Subtract two numbers."""
    return a - b


def multiply(a, b):
    """Multiply two numbers."""
    return a * b


def divide(a, b):
    """Divide two numbers - VULNERABLE to division by zero."""
    # VULNERABILITY: No check for zero divisor
    return a / b


if __name__ == "__main__":
    print(divide(10, 2))  # Works
    # print(divide(10, 0))  # Crashes!
