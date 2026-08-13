#!/usr/bin/env python3
"""
Trace Client - Generate sample requests to test distributed tracing
"""

import asyncio
import httpx
import json
import random
from datetime import datetime

BASE_URL = "http://localhost:8003"

# Sample data
VALID_USER_IDS = [1, 2, 3]
VALID_PRODUCT_IDS = [1, 2, 3, 4, 5, 6]

async def create_order(client: httpx.AsyncClient):
    """Create an order and trace the entire flow"""
    order_data = {
        "user_id": random.choice(VALID_USER_IDS),
        "product_id": random.choice(VALID_PRODUCT_IDS),
        "quantity": random.randint(1, 3)
    }

    try:
        response = await client.post(
            f"{BASE_URL}/orders",
            json=order_data,
            timeout=10.0
        )
        response.raise_for_status()
        result = response.json()

        print(f"✅ Created order {result.get('id')}")
        print(f"   User: {result.get('user_email')}")
        print(f"   Product: {result.get('product_name')}")
        print(f"   Total: ${result.get('total_price'):.2f}")

        return result

    except httpx.HTTPError as e:
        print(f"❌ Error creating order: {e}")
        return None

async def get_order(client: httpx.AsyncClient, order_id: int):
    """Get order details"""
    try:
        response = await client.get(f"{BASE_URL}/orders/{order_id}", timeout=5.0)
        response.raise_for_status()
        print(f"✅ Retrieved order {order_id}: {response.json()}")
        return response.json()

    except httpx.HTTPError as e:
        print(f"❌ Error getting order: {e}")
        return None

async def get_health(client: httpx.AsyncClient):
    """Check health of order-service"""
    try:
        response = await client.get(f"{BASE_URL}/health", timeout=5.0)
        response.raise_for_status()
        print(f"✅ Order Service Health: {response.json()}")
        return True

    except httpx.HTTPError as e:
        print(f"❌ Order Service health check failed: {e}")
        return False

async def main():
    """Main test runner"""
    print("=" * 70)
    print("🔍 Jaeger Distributed Tracing - Test Client")
    print("=" * 70)
    print()

    async with httpx.AsyncClient() as client:
        # Check health
        print("1️⃣  Checking service health...")
        healthy = await get_health(client)
        if not healthy:
            print("❌ Service not available. Start with: make up")
            return

        print()
        print("2️⃣  Creating sample orders to generate traces...")
        print()

        # Create multiple orders to generate traces
        order_ids = []
        for i in range(5):
            print(f"Request {i+1}/5:")
            order = await create_order(client)
            if order:
                order_ids.append(order.get("id"))
            print()
            await asyncio.sleep(0.5)  # Stagger requests

        if not order_ids:
            print("❌ No orders created. Check service logs.")
            return

        print("=" * 70)
        print("3️⃣  Generated Traces")
        print("=" * 70)
        print()
        print("✅ Successfully created", len(order_ids), "orders with distributed traces!")
        print()
        print("📊 Next steps:")
        print("   1. Open Jaeger UI: http://localhost:16686")
        print("   2. Select Service: 'order-service'")
        print("   3. Operation: 'POST /orders'")
        print("   4. Click on traces to see:")
        print("      - Full request journey across microservices")
        print("      - Latency breakdown by service")
        print("      - Dependencies: order → user → product")
        print()
        print("📈 For load testing:")
        print("   make load-test")
        print()
        print("=" * 70)

if __name__ == "__main__":
    asyncio.run(main())
