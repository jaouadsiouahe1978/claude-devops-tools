"""
User Service - Microservice with OpenTelemetry Tracing
Provides user management endpoints
"""

import logging
import os
import json
import random
from datetime import datetime
from typing import Optional

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, EmailStr
from fastapi.responses import JSONResponse
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

    # Jaeger exporter configuration
    jaeger_exporter = JaegerExporter(
        agent_host_name=os.getenv("JAEGER_AGENT_HOST", "localhost"),
        agent_port=int(os.getenv("JAEGER_AGENT_PORT", "6831")),
    )

    # Create trace provider
    trace_provider = TracerProvider(
        resource=Resource.create(
            {
                SERVICE_NAME: "user-service",
                "service.version": "1.0.0",
                "service.environment": os.getenv("ENVIRONMENT", "development"),
            }
        )
    )
    trace_provider.add_span_processor(BatchSpanProcessor(jaeger_exporter))
    trace.set_tracer_provider(trace_provider)

    # Prometheus metrics
    prometheus_reader = PrometheusMetricReader()
    meter_provider = MeterProvider(metric_readers=[prometheus_reader])
    metrics.set_meter_provider(meter_provider)

    logger.info("✅ OpenTelemetry initialized")
    logger.info(f"   Jaeger Agent: {os.getenv('JAEGER_AGENT_HOST', 'localhost')}:{os.getenv('JAEGER_AGENT_PORT', '6831')}")

    # Instrument popular libraries
    FastAPIInstrumentor.instrument_app(app)
    SQLite3Instrumentor().instrument()
    RequestsInstrumentor().instrument()

# ============================================================================
# FastAPI App
# ============================================================================

app = FastAPI(
    title="User Service",
    description="Microservice for user management with OpenTelemetry tracing",
    version="1.0.0"
)

tracer = trace.get_tracer(__name__)

# ============================================================================
# Database Setup
# ============================================================================

DB_FILE = "/tmp/users.db"

def init_db():
    """Initialize SQLite database"""
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE NOT NULL,
            name TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)

    # Insert sample users
    try:
        sample_users = [
            ("alice@example.com", "Alice Johnson"),
            ("bob@example.com", "Bob Smith"),
            ("charlie@example.com", "Charlie Brown"),
        ]
        cursor.executemany(
            "INSERT OR IGNORE INTO users (email, name) VALUES (?, ?)",
            sample_users
        )
    except Exception as e:
        logger.warning(f"Could not insert sample users: {e}")

    conn.commit()
    conn.close()

# Initialize DB on startup
init_db()

# ============================================================================
# Data Models
# ============================================================================

class User(BaseModel):
    id: Optional[int] = None
    email: EmailStr
    name: str
    created_at: Optional[str] = None

class UserCreate(BaseModel):
    email: EmailStr
    name: str

# ============================================================================
# Health Check Endpoint
# ============================================================================

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    with tracer.start_as_current_span("health_check") as span:
        span.set_attribute("service", "user-service")
        return {
            "status": "healthy",
            "service": "user-service",
            "timestamp": datetime.utcnow().isoformat()
        }

# ============================================================================
# User Endpoints
# ============================================================================

@app.get("/users")
async def list_users(limit: int = 10):
    """List all users"""
    with tracer.start_as_current_span("list_users") as span:
        span.set_attribute("limit", limit)

        try:
            conn = sqlite3.connect(DB_FILE)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()

            cursor.execute("SELECT id, email, name, created_at FROM users LIMIT ?", (limit,))
            rows = cursor.fetchall()
            conn.close()

            users = [dict(row) for row in rows]
            span.set_attribute("user_count", len(users))

            logger.info(f"📋 Listed {len(users)} users")
            return {"users": users, "count": len(users)}

        except Exception as e:
            span.record_exception(e)
            span.set_attribute("error", True)
            logger.error(f"❌ Error listing users: {e}")
            raise HTTPException(status_code=500, detail=str(e))

@app.get("/users/{user_id}")
async def get_user(user_id: int):
    """Get user by ID"""
    with tracer.start_as_current_span("get_user") as span:
        span.set_attribute("user_id", user_id)

        # Add baggage for correlation
        baggage.set_baggage("user_id", str(user_id))

        try:
            conn = sqlite3.connect(DB_FILE)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()

            cursor.execute(
                "SELECT id, email, name, created_at FROM users WHERE id = ?",
                (user_id,)
            )
            row = cursor.fetchone()
            conn.close()

            if not row:
                span.set_attribute("not_found", True)
                raise HTTPException(status_code=404, detail="User not found")

            user = dict(row)
            span.set_attribute("email", user["email"])
            logger.info(f"👤 Got user {user_id}: {user['email']}")

            return user

        except HTTPException:
            raise
        except Exception as e:
            span.record_exception(e)
            span.set_attribute("error", True)
            logger.error(f"❌ Error getting user {user_id}: {e}")
            raise HTTPException(status_code=500, detail=str(e))

@app.post("/users")
async def create_user(user: UserCreate):
    """Create new user"""
    with tracer.start_as_current_span("create_user") as span:
        span.set_attribute("email", user.email)
        span.set_attribute("name", user.name)

        try:
            conn = sqlite3.connect(DB_FILE)
            cursor = conn.cursor()

            cursor.execute(
                "INSERT INTO users (email, name) VALUES (?, ?)",
                (user.email, user.name)
            )
            conn.commit()
            user_id = cursor.lastrowid
            conn.close()

            span.set_attribute("user_id", user_id)
            logger.info(f"✨ Created user {user_id}: {user.email}")

            return {
                "id": user_id,
                "email": user.email,
                "name": user.name,
                "created_at": datetime.utcnow().isoformat()
            }

        except sqlite3.IntegrityError as e:
            span.record_exception(e)
            span.set_attribute("error", True)
            logger.error(f"❌ Email already exists: {user.email}")
            raise HTTPException(status_code=409, detail="Email already exists")
        except Exception as e:
            span.record_exception(e)
            span.set_attribute("error", True)
            logger.error(f"❌ Error creating user: {e}")
            raise HTTPException(status_code=500, detail=str(e))

@app.get("/users/{user_id}/profile")
async def get_user_profile(user_id: int):
    """Get detailed user profile with simulated enrichment"""
    with tracer.start_as_current_span("get_user_profile") as span:
        span.set_attribute("user_id", user_id)

        try:
            # Get basic user info
            with tracer.start_as_current_span("fetch_user_data") as sub_span:
                conn = sqlite3.connect(DB_FILE)
                conn.row_factory = sqlite3.Row
                cursor = conn.cursor()
                cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))
                row = cursor.fetchone()
                conn.close()

                if not row:
                    raise HTTPException(status_code=404, detail="User not found")

                user = dict(row)
                sub_span.set_attribute("email", user["email"])

            # Simulate enrichment (e.g., from cache/API)
            with tracer.start_as_current_span("enrich_profile") as sub_span:
                sub_span.set_attribute("source", "enrichment_service")
                # Simulate cache lookup
                profile_data = {
                    "user_id": user_id,
                    "email": user["email"],
                    "name": user["name"],
                    "preferences": {
                        "notifications": True,
                        "newsletter": random.choice([True, False])
                    },
                    "account_status": "active",
                    "last_login": datetime.utcnow().isoformat()
                }

            span.set_attribute("profile_complete", True)
            logger.info(f"👤 Retrieved full profile for user {user_id}")

            return profile_data

        except HTTPException:
            raise
        except Exception as e:
            span.record_exception(e)
            span.set_attribute("error", True)
            logger.error(f"❌ Error getting profile: {e}")
            raise HTTPException(status_code=500, detail=str(e))

# ============================================================================
# Metrics Endpoint (for Prometheus)
# ============================================================================

@app.get("/metrics")
async def metrics():
    """Prometheus metrics endpoint"""
    from opentelemetry.exporter.prometheus import PrometheusMetricReader
    try:
        # This would be handled by prometheus client middleware
        return JSONResponse({"status": "metrics endpoint"})
    except Exception as e:
        return JSONResponse({"error": str(e)}, status_code=500)

# ============================================================================
# Startup & Shutdown
# ============================================================================

@app.on_event("startup")
async def startup_event():
    logger.info("🚀 User Service starting up...")
    init_otel()
    logger.info("✅ User Service ready")

@app.on_event("shutdown")
async def shutdown_event():
    logger.info("🛑 User Service shutting down...")
    trace.get_tracer_provider().force_flush()

# ============================================================================
# Run
# ============================================================================

if __name__ == "__main__":
    import uvicorn

    port = int(os.getenv("PORT", "8001"))
    logger.info(f"Starting User Service on port {port}...")

    uvicorn.run(
        app,
        host="0.0.0.0",
        port=port,
        log_level="info"
    )
