"""
Hardcoded Secrets Vulnerability Demo

This file demonstrates a critical security vulnerability
where API keys are hardcoded directly in source code.

Forge will detect this and fix it using environment variables.
"""
import requests

# VULNERABILITY: Hardcoded API key in source code
API_KEY = 'sk_live_abc123xyz789'


class PaymentClient:
    """Payment API client - VULNERABLE with hardcoded credentials."""

    def __init__(self):
        self.base_url = "https://api.payment.com"

    def charge(self, amount, card_token):
        """Charge a payment method."""
        return requests.post(
            f"{self.base_url}/charge",
            headers={"Authorization": f"Bearer {API_KEY}"},
            json={"amount": amount, "token": card_token}
        )

    def refund(self, charge_id):
        """Refund a charge."""
        return requests.post(
            f"{self.base_url}/refund/{charge_id}",
            headers={"Authorization": f"Bearer {API_KEY}"}
        )
