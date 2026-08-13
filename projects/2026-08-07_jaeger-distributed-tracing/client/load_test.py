"""
Load Testing Client - Generate sustained traffic for trace analysis
Uses Locust framework for distributed load testing
"""

from locust import HttpUser, task, between
import random
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class OrderServiceUser(HttpUser):
    """Simulated user for order service"""

    wait_time = between(1, 3)  # Wait 1-3 seconds between requests

    VALID_USERS = [1, 2, 3]
    VALID_PRODUCTS = [1, 2, 3, 4, 5, 6]

    @task(3)
    def create_order(self):
        """Create an order (most common operation)"""
        order_data = {
            "user_id": random.choice(self.VALID_USERS),
            "product_id": random.choice(self.VALID_PRODUCTS),
            "quantity": random.randint(1, 3)
        }

        with self.client.post(
            "/orders",
            json=order_data,
            catch_response=True
        ) as response:
            if response.status_code == 200:
                response.success()
                logger.info(f"✅ Order created: {response.json().get('id')}")
            else:
                response.failure(f"Failed with status {response.status_code}")
                logger.error(f"❌ Order creation failed: {response.text}")

    @task(1)
    def list_orders(self):
        """List orders (less common)"""
        with self.client.get(
            "/orders?limit=10",
            catch_response=True
        ) as response:
            if response.status_code == 200:
                response.success()
                count = response.json().get("count", 0)
                logger.info(f"✅ Listed {count} orders")
            else:
                response.failure(f"Failed with status {response.status_code}")

    @task(1)
    def health_check(self):
        """Health check (minimal traffic)"""
        with self.client.get(
            "/health",
            catch_response=True
        ) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Health check failed: {response.status_code}")

class OrderServiceAdmin(HttpUser):
    """Admin user that performs different operations"""

    wait_time = between(5, 10)

    @task
    def get_order(self):
        """Retrieve specific orders"""
        order_id = random.randint(1, 10)
        with self.client.get(
            f"/orders/{order_id}",
            catch_response=True
        ) as response:
            if response.status_code in [200, 404]:  # 404 is expected if order doesn't exist
                response.success()
            else:
                response.failure(f"Failed with status {response.status_code}")
