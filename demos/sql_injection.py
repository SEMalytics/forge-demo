"""
SQL Injection Vulnerability Demo

This file demonstrates a common SQL injection vulnerability
where user input is directly concatenated into a SQL query.

Forge will detect this and fix it using parameterized queries.
"""
import sqlite3


def get_user_by_username(username):
    """Get user from database - VULNERABLE to SQL injection."""
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    # VULNERABILITY: User input directly in query string
    query = f"SELECT * FROM users WHERE username = '{username}'"
    cursor.execute(query)
    result = cursor.fetchone()
    conn.close()
    return result


if __name__ == "__main__":
    # Example: Normal usage
    print(get_user_by_username("admin"))

    # Attack: SQL injection would work here
    # get_user_by_username("' OR '1'='1")
