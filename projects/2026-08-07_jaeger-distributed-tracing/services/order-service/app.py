"""
Order Service - Microservice with OpenTelemetry Tracing
Provides order management with inter-service communication
This service calls user-service and product-service
"""

import logging
import os
import json
from datetime import datetime
from typing import Optional

import httpx
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import sqlite3

# OpenTelemetry imports
from opentelemetry import trace, metrics, baggage
from opentelemetry.exporter.jaeger.thrift import JaegerExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.sqlite3 import SQLite3Instrumentor
from opentelemetry.instrumentation.httpx import HTTPXClientInstrumentor
from opentelemetry.sdk.resources import SERVICE_NAME, Resource
from opentelemetry.exporter.prometheus import PrometheusMetricReader
from opentelemetry.sdk.metrics import MeterProvider

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ============================================================================
# OpenTelemetry Configuration
# ============================================================================

def init_otel():
    """Initialize OpenTelemetry tracing and metrics"""

    jaeger_exporter = JaegerExporter(
        agent_host_name=os.getenv("JAEGER_AGENT_HOST", "localhost"),
        agent_port=int(os.getenv("JAEGER_AGENT_PORT", "6831")),
    )

    trace_provider = TracerProvider(
        resource=Resource.create(
            {
                SERVICE_NAME: "order-service",
                "service.version": "1.0.0",
                "service.environment": os.getenv("ENVIRONMENT", "development"),
            }
        )
    )
    trace_provider.add_span_processor(BatchSpanProcessor(jaeger_exporter))
    trace.set_tracer_provider(trace_provider)

    prometheus_reader = PrometheusMetricReader()
    meter_provider = MeterProvider(metric_readers=[prometheus_reader])
    metrics.set_meter_provider(meter_provider)

    logger.info("✅ OpenTelemetry initialized")
    logger.info(f"   Jaeger Agent: {os.getenv('JAEGER_AGENT_HOST', 'localhost')}:{os.getenv('JAEGER_AGENT_PORT', '6831')}")

    FastAPIInstrumentor.instrument_app(app)
    SQLite3Instrumentor().instrument()
    HTTPXClientInstrumentor().instrument()

# ============================================================================
# FastAPI App
# ============================================================================

app = FastAPI(
    title="Order Service",
    description="Microservice for order management with distributed tracing",
    version="1.0.0"
)

tracer = trace.get_tracer(__name__)

# ============================================================================
# Service URLs
# ============================================================================

USER_SERVICE_URL = os.getenv("USER_SERVICE_URL", "http://user-service:8001")
PRODUCT_SERVICE_URL = os.getenv("PRODUCT_SERVICE_URL", "http://product-service:8002")

# ============================================================================
# Database Setup
# ============================================================================

DB_FILE = "/tmp/orders.db"

def init_db():
    """Initialize SQLite database"""
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            quantity INTEGER NOT NULL,
            total_price REAL NOT NULL,
            status TEXT DEFAULT 'pending',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.commit()
    conn.close()

init_db()

# ============================================================================
# Data Models
# ============================================================================

class OrderCreate(BaseModel):
    user_id: int
    product_id: int
    quantity: int

class Order(BaseModel):
    id: Optional[int] = None
    user_id: int
    product_id: int
    quantity: int
    total_price: float
    status: str
    created_at: Optional[str] = None

# ============================================================================
# Health Check Endpoint
# ============================================================================

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    with tracer.start_as_current_span("health_check") as span:
        span.set_attribute("service", "order-service")
        return {
            "status": "healthy",
            "service": "order-service",
            "timestamp": datetime.utcnow().isoformat()
        }

# ============================================================================
# Helper Functions (with spans)
# ============================================================================

async def get_user_info(user_id: int):
    """Call user-service to get user info"""
    with tracer.start_as_current_span("call_user_service") as span:
        span.set_attribute("user_id", user_id)
        span.set_attribute("service", "user-service")

        try:
            async with httpx.AsyncClient() as client:
                url = f"{USER_SERVICE_URL}/users/{user_id}"
                response = await client.get(url, timeout=5.0)

                span.set_attribute("http.status_code", response.status_code)

                if response.status_code == 404:
                    raise HTTPException(status_code=404, detail="User not found")

                response.raise_for_status()
                user = response.json()

                span.set_attribute("user_email", user.get("email"))
                logger.info(f"✅ Got user {user_id} info from user-service")

                return user

        except httpx.HTTPError as e:
            span.record_exception(e)
            span.set_attribute("error", True)
            logger.error(f"❌ Error calling user-service: {e}")
            raise HTTPException(status_code=503, detail="User service unavailable")

async def get_product_info(product_id: int):
    """Call product-service to get product info"""
    with tracer.start_as_current_span("call_product_service") as span:
        span.set_attribute("product_id", product_id)
        span.set_attribute("service", "product-service")

        try:
            async with httpx.AsyncClient() as client:
                url = f"{PRODUCT_SERVICE_URL}/products/{product_id}"
                response = await client.get(url, timeout=5.0)

                span.set_attribute("http.status_code", response.status_code)

                if response.status_code == 404:
                    raise HTTPException(status_code=404, detail="Product not found")

                response.raise_for_status()
                product = response.json()

                span.set_attribute("product_name", product.get("name"))
                span.set_attribute("product_price", product.get("price"))
                logger.info(f"✅ Got product {product_id} info from product-service")

                return product

        except httpx.HTTPError as e:
            span.record_exception(e)
            span.set_attribute("error", True)
            logger.error(f"❌ Error calling product-service: {e}")
            raise HTTPException(status_code=503, detail="Product service unavailable")

async def reserve_product(product_id: int, quantity: int):
    """Call product-service to reserve stock"""
    with tracer.start_as_current_span("reserve_product_stock") as span:
        span.set_attribute("product_id", product_id)
        span.set_attribute("quantity", quantity)
        span.set_attribute("service", "product-service")

        try:
            async with httpx.AsyncClient() as client:
                url = f"{PRODUCT_SERVICE_URL}/products/{product_id}/reserve"
                response = await client.post(
                    url,
                    json={"quantity": quantity},
                    timeout=5.0
                )

                span.set_attribute("http.status_code", response.status_code)
                response.raise_for_status()

                result = response.json()
                span.set_attribute("stock_remaining", result.get("stock_remaining"))
                logger.info(f"✅ Reserved {quantity} units of product {product_id}")

                return result

        except httpx.HTTPError as e:
            span.record_exception(e)
            span.set_attribute("error", True)
            logger.error(f"❌ Error reserving product stock: {e}")
            raise HTTPException(status_code=503, detail="Could not reserve product")

# ============================================================================
# Order Endpoints
# ============================================================================

@app.get("/orders")
async def list_orders(limit: int = 20):
    """List all orders"""
    with tracer.start_as_current_span("list_orders") as span:
        span.set_attribute("limit", limit)

        try:
            conn = sqlite3.connect(DB_FILE)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()

            cursor.execute(
                "SELECT id, user_id, product_id, quantity, total_price, status FROM orders LIMIT ?",
                (limit,)
            )
            rows = cursor.fetchall()
            conn.close()

            orders = [dict(row) for row in rows]
            span.set_attribute("order_count", len(orders))

            logger.info(f"📋 Listed {len(orders)} orders")
            return {"orders": orders, "count": len(orders)}

        except Exception as e:
            span.record_exception(e)
            span.set_attribute("error", True)
            logger.error(f"❌ Error listing orders: {e}")
            raise HTTPException(status_code=500, detail=str(e))

@app.get("/orders/{order_id}")
async def get_order(order_id: int):
    """Get order details"""
    with tracer.start_as_current_span("get_order") as span:
        span.set_attribute("order_id", order_id)
        baggage.set_baggage("order_id", str(order_id))

        try:
            conn = sqlite3.connect(DB_FILE)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()

            cursor.execute(
                "SELECT id, user_id, product_id, quantity, total_price, status FROM orders WHERE id = ?",
                (order_id,)
            )
            row = cursor.fetchone()
            conn.close()

            if not row:
                span.set_attribute("not_found", True)
                raise HTTPException(status_code=404, detail="Order not found")

            order = dict(row)
            span.set_attribute("user_id", order["user_id"])
            span.set_attribute("status", order["status"])
            logger.info(f"📦 Got order {order_id}")

            return order

        except HTTPException:
            raise
        except Exception as e:
            span.record_exception(e)
            span.set_attribute("error", True)
            logger.error(f"❌ Error getting order {order_id}: {e}")
            raise HTTPException(status_code=500, detail=str(e))

@app.post("/orders")
async def create_order(order: OrderCreate):
    """
    Create a new order

    This endpoint demonstrates distributed tracing across multiple services:
    1. Validate user exists (user-service)
    2. Get product details (product-service)
    3. Reserve stock (product-service)
    4. Save order (local database)
    """
    with tracer.start_as_current_span("create_order") as span:
        span.set_attribute("user_id", order.user_id)
        span.set_attribute("product_id", order.product_id)
        span.set_attribute("quantity", order.quantity)

        # Add correlation IDs to baggage for downstream services
        baggage.set_baggage("user_id", str(order.user_id))
        baggage.set_baggage("product_id", str(order.product_id))

        try:
            # Step 1: Validate user
            logger.info(f"🔍 Step 1: Validating user {order.user_id}...")
            user = await get_user_info(order.user_id)

            # Step 2: Get product info
            logger.info(f"🔍 Step 2: Getting product {order.product_id} details...")
            product = await get_product_info(order.product_id)

            # Step 3: Reserve stock
            logger.info(f"🔍 Step 3: Reserving {order.quantity} units...")
            await reserve_product(order.product_id, order.quantity)

            # Step 4: Create order in database
            logger.info(f"🔍 Step 4: Creating order in database...")
            with tracer.start_as_current_span("save_order_to_db") as db_span:
                conn = sqlite3.connect(DB_FILE)
                cursor = conn.cursor()

                total_price = product["price"] * order.quantity

                cursor.execute(
                    "INSERT INTO orders (user_id, product_id, quantity, total_price, status) VALUES (?, ?, ?, ?, ?)",
                    (order.user_id, order.product_id, order.quantity, total_price, "pending")
                )
                conn.commit()
                order_id = cursor.lastrowid
                conn.close()

                db_span.set_attribute("order_id", order_id)
                db_span.set_attribute("total_price", total_price)

            span.set_attribute("order_id", order_id)
            span.set_attribute("total_price", total_price)
            span.set_attribute("status", "pending")

            logger.info(f"✨ Created order {order_id}: User {order.user_id}, Product {order.product_id}, Qty {order.quantity}")

            return {
                "id": order_id,
                "user_id": order.user_id,
                "product_id": order.product_id,
                "quantity": order.quantity,
                "total_price": total_price,
                "status": "pending",
                "created_at": datetime.utcnow().isoformat(),
                "user_email": user.get("email"),
                "product_name": product.get("name")
            }

        except HTTPException:
            raise
        except Exception as e:
            span.record_exception(e)
            span.set_attribute("error", True)
            logger.error(f"❌ Error creating order: {e}")
            raise HTTPException(status_code=500, detail=str(e))

# ============================================================================
# Startup & Shutdown
# ============================================================================

@app.on_event("startup")
async def startup_event():
    logger.info("🚀 Order Service starting up...")
    init_otel()
    logger.info(f"✅ Order Service ready")
    logger.info(f"   User Service: {USER_SERVICE_URL}")
    logger.info(f"   Product Service: {PRODUCT_SERVICE_URL}")

@app.on_event("shutdown")
async def shutdown_event():
    logger.info("🛑 Order Service shutting down...")
    trace.get_tracer_provider().force_flush()

# ============================================================================
# Run
# ============================================================================

if __name__ == "__main__":
    import uvicorn

    port = int(os.getenv("PORT", "8003"))
    logger.info(f"Starting Order Service on port {port}...")

    uvicorn.run(
        app,
        host="0.0.0.0",
        port=port,
        log_level="info"
    )
