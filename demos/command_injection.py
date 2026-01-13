"""
Command Injection Vulnerability Demo

This file demonstrates a command injection vulnerability
where user input is passed directly to os.system().

Forge will detect this and fix it using subprocess with proper escaping.
"""
import os


def process_file(filename):
    """Display file contents - VULNERABLE to command injection."""
    # VULNERABILITY: User input passed directly to shell
    os.system(f"cat {filename}")


if __name__ == "__main__":
    # Example: Normal usage
    process_file("test.txt")

    # Attack: Command injection would work here
    # process_file("test.txt; rm -rf /")
