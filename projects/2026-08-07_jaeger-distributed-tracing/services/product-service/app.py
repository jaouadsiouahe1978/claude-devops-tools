"""
Product Service - Microservice with OpenTelemetry Tracing
Provides product catalog endpoints
"""

import logging
import os
import json
from datetime import datetime
from typing import Optional

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
from opentelemetry.instrumentation.requests import RequestsInstrumentor
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
                SERVICE_NAME: "product-service",
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
    RequestsInstrumentor().instrument()

# ============================================================================
# FastAPI App
# ============================================================================

app = FastAPI(
    title="Product Service",
    description="Microservice for product catalog with OpenTelemetry tracing",
    version="1.0.0"
)

tracer = trace.get_tracer(__name__)

# ============================================================================
# Database Setup
# ============================================================================

DB_FILE = "/tmp/products.db"

def init_db():
    """Initialize SQLite database with sample products"""
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            price REAL NOT NULL,
            stock INTEGER NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)

    try:
        sample_products = [
            ("Laptop", "Electronics", 999.99, 15),
            ("Mouse", "Electronics", 29.99, 100),
            ("Keyboard", "Electronics", 79.99, 50),
            ("Monitor", "Electronics", 299.99, 20),
            ("USB Cable", "Accessories", 9.99, 200),
            ("Phone Case", "Accessories", 19.99, 150),
        ]
        cursor.executemany(
            "INSERT OR IGNORE INTO products (name, category, price, stock) VALUES (?, ?, ?, ?)",
            sample_products
        )
    except Exception as e:
        logger.warning(f"Could not insert sample products: {e}")

    conn.commit()
    conn.close()

init_db()

# ============================================================================
# Data Models
# ============================================================================

class Product(BaseModel):
    id: Optional[int] = None
    name: str
    category: str
    price: float
    stock: int
    created_at: Optional[str] = None

class ProductCreate(BaseModel):
    name: str
    category: str
    price: float
    stock: int

# ============================================================================
# Health Check Endpoint
# ============================================================================

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    with tracer.start_as_current_span("health_check") as span:
        span.set_attribute("service", "product-service")
        return {
            "status": "healthy",
            "service": "product-service",
            "timestamp": datetime.utcnow().isoformat()
        }

# ============================================================================
# Product Endpoints
# ============================================================================

@app.get("/products")
async def list_products(category: Optional[str] = None, limit: int = 20):
    """List all products, optionally filtered by category"""
    with tracer.start_as_current_span("list_products") as span:
        span.set_attribute("category_filter", category or "all")
        span.set_attribute("limit", limit)

        try:
            conn = sqlite3.connect(DB_FILE)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()

            if category:
                cursor.execute(
                    "SELECT id, name, category, price, stock FROM products WHERE category = ? LIMIT ?",
                    (category, limit)
                )
            else:
                cursor.execute(
                    "SELECT id, name, category, price, stock FROM products LIMIT ?",
                    (limit,)
                )

            rows = cursor.fetchall()
            conn.close()

            products = [dict(row) for row in rows]
            span.set_attribute("product_count", len(products))

            logger.info(f"📦 Listed {len(products)} products")
            return {"products": products, "count": len(products)}

        except Exception as e:
            span.record_exception(e)
            span.set_attribute("error", True)
            logger.error(f"❌ Error listing products: {e}")
            raise HTTPException(status_code=500, detail=str(e))

@app.get("/products/{product_id}")
async def get_product(product_id: int):
    """Get product details by ID"""
    with tracer.start_as_current_span("get_product") as span:
        span.set_attribute("product_id", product_id)
        baggage.set_baggage("product_id", str(product_id))

        try:
            conn = sqlite3.connect(DB_FILE)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()

            cursor.execute(
                "SELECT id, name, category, price, stock FROM products WHERE id = ?",
                (product_id,)
            )
            row = cursor.fetchone()
            conn.close()

            if not row:
                span.set_attribute("not_found", True)
                raise HTTPException(status_code=404, detail="Product not found")

            product = dict(row)
            span.set_attribute("name", product["name"])
            span.set_attribute("price", product["price"])
            span.set_attribute("stock", product["stock"])

            logger.info(f"🛍️  Got product {product_id}: {product['name']}")
            return product

        except HTTPException:
            raise
        except Exception as e:
            span.record_exception(e)
            span.set_attribute("error", True)
            logger.error(f"❌ Error getting product {product_id}: {e}")
            raise HTTPException(status_code=500, detail=str(e))

@app.post("/products")
async def create_product(product: ProductCreate):
    """Create new product"""
    with tracer.start_as_current_span("create_product") as span:
        span.set_attribute("name", product.name)
        span.set_attribute("category", product.category)
        span.set_attribute("price", product.price)

        try:
            conn = sqlite3.connect(DB_FILE)
            cursor = conn.cursor()

            cursor.execute(
                "INSERT INTO products (name, category, price, stock) VALUES (?, ?, ?, ?)",
                (product.name, product.category, product.price, product.stock)
            )
            conn.commit()
            product_id = cursor.lastrowid
            conn.close()

            span.set_attribute("product_id", product_id)
            logger.info(f"✨ Created product {product_id}: {product.name}")

            return {
                "id": product_id,
                "name": product.name,
                "category": product.category,
                "price": product.price,
                "stock": product.stock,
                "created_at": datetime.utcnow().isoformat()
            }

        except Exception as e:
            span.record_exception(e)
            span.set_attribute("error", True)
            logger.error(f"❌ Error creating product: {e}")
            raise HTTPException(status_code=500, detail=str(e))

@app.post("/products/{product_id}/reserve")
async def reserve_product(product_id: int, quantity: int = 1):
    """Reserve stock for a product (for orders)"""
    with tracer.start_as_current_span("reserve_product") as span:
        span.set_attribute("product_id", product_id)
        span.set_attribute("quantity", quantity)

        try:
            conn = sqlite3.connect(DB_FILE)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()

            # Check current stock
            cursor.execute("SELECT stock, name FROM products WHERE id = ?", (product_id,))
            row = cursor.fetchone()

            if not row:
                span.set_attribute("not_found", True)
                conn.close()
                raise HTTPException(status_code=404, detail="Product not found")

            current_stock = row["stock"]
            product_name = row["name"]

            if current_stock < quantity:
                span.set_attribute("insufficient_stock", True)
                span.set_attribute("available", current_stock)
                conn.close()
                raise HTTPException(
                    status_code=400,
                    detail=f"Insufficient stock. Available: {current_stock}, Requested: {quantity}"
                )

            # Update stock
            cursor.execute(
                "UPDATE products SET stock = stock - ? WHERE id = ?",
                (quantity, product_id)
            )
            conn.commit()
            conn.close()

            span.set_attribute("product_name", product_name)
            span.set_attribute("new_stock", current_stock - quantity)
            logger.info(f"📦 Reserved {quantity} units of {product_name}")

            return {
                "product_id": product_id,
                "product_name": product_name,
                "quantity_reserved": quantity,
                "stock_remaining": current_stock - quantity
            }

        except HTTPException:
            raise
        except Exception as e:
            span.record_exception(e)
            span.set_attribute("error", True)
            logger.error(f"❌ Error reserving product: {e}")
            raise HTTPException(status_code=500, detail=str(e))

# ============================================================================
# Startup & Shutdown
# ============================================================================

@app.on_event("startup")
async def startup_event():
    logger.info("🚀 Product Service starting up...")
    init_otel()
    logger.info("✅ Product Service ready")

@app.on_event("shutdown")
async def shutdown_event():
    logger.info("🛑 Product Service shutting down...")
    trace.get_tracer_provider().force_flush()

# ============================================================================
# Run
# ============================================================================

if __name__ == "__main__":
    import uvicorn

    port = int(os.getenv("PORT", "8002"))
    logger.info(f"Starting Product Service on port {port}...")

    uvicorn.run(
        app,
        host="0.0.0.0",
        port=port,
        log_level="info"
    )
