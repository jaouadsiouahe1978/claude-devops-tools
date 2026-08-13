# OpenTelemetry Instrumentation Guide

## Overview

This guide explains how the three microservices are instrumented with OpenTelemetry for distributed tracing with Jaeger.

---

## 1. Initialization

### Jaeger Exporter Setup

```python
from opentelemetry.exporter.jaeger.thrift import JaegerExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

# Create exporter
jaeger_exporter = JaegerExporter(
    agent_host_name="jaeger",      # Container name in Docker network
    agent_port=6831,                # Thrift UDP port
)

# Create trace provider
trace_provider = TracerProvider(
    resource=Resource.create({
        "service.name": "order-service",
        "service.version": "1.0.0",
    })
)

# Add span processor (batches spans for efficiency)
trace_provider.add_span_processor(
    BatchSpanProcessor(jaeger_exporter)
)

# Set as global provider
trace.set_tracer_provider(trace_provider)
```

### Auto-Instrumentation

The services automatically instrument popular libraries:

```python
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.sqlite3 import SQLite3Instrumentor
from opentelemetry.instrumentation.httpx import HTTPXClientInstrumentor

# Instrument FastAPI
FastAPIInstrumentor.instrument_app(app)

# Instrument database
SQLite3Instrumentor().instrument()

# Instrument HTTP client
HTTPXClientInstrumentor().instrument()
```

This automatically creates spans for:
- HTTP requests/responses
- Database queries
- External service calls

---

## 2. Manual Span Creation

### Basic Span

```python
from opentelemetry import trace

tracer = trace.get_tracer(__name__)

with tracer.start_as_current_span("operation_name") as span:
    span.set_attribute("user_id", 123)
    span.set_attribute("email", "user@example.com")
    # Your code here
```

### With Exception Handling

```python
with tracer.start_as_current_span("fetch_user") as span:
    try:
        user = database.get_user(user_id)
        span.set_attribute("email", user.email)
    except Exception as e:
        span.record_exception(e)  # Record the exception
        span.set_attribute("error", True)
        raise
```

### Nested Spans

```python
with tracer.start_as_current_span("create_order") as parent_span:
    parent_span.set_attribute("order_id", 456)
    
    # This becomes a child span automatically
    with tracer.start_as_current_span("validate_payment") as child_span:
        child_span.set_attribute("amount", 99.99)
        # validation logic
    
    # Another child span
    with tracer.start_as_current_span("persist_to_db") as child_span:
        child_span.set_attribute("table", "orders")
        # database logic
```

---

## 3. Trace Context Propagation

### Problem: How does Order Service know about traces from User Service?

The W3C Trace Context standard propagates trace ID across services:

```
Request 1: Client → Order Service
    traceparent: 00-{trace_id}-{span_id}-01

Request 2: Order Service → User Service (automatic header injection)
    traceparent: 00-{trace_id}-{span_id_2}-01
    ↑ Same trace_id! Spans are linked!

Result: Single trace showing full request journey
```

### Manual Propagation (if needed)

```python
from opentelemetry.propagate import inject, extract
from opentelemetry import trace

# Sending request
headers = {}
inject(headers)  # Adds traceparent and baggage headers

async with httpx.AsyncClient() as client:
    response = await client.get(url, headers=headers)

# Receiving request (FastAPI auto-handles this)
context = extract(request.headers)  # Extracts context from headers
```

---

## 4. Baggage (Cross-Cutting Concerns)

Baggage allows propagating metadata across the entire trace without modifying every service.

### Setting Baggage

```python
from opentelemetry import baggage

# Set baggage in order-service
baggage.set_baggage("user_id", "123")
baggage.set_baggage("correlation_id", "abc-def-ghi")

# Automatically propagated to user-service and product-service!
```

### Reading Baggage

```python
from opentelemetry import baggage

# In user-service, access baggage set by order-service
user_id = baggage.get_baggage("user_id")  # Returns "123"
correlation_id = baggage.get_baggage("correlation_id")

# Use in your application logic
logger.info(f"Processing request for user {user_id}")
```

### Common Baggage Items

- `correlation_id` - Unique request ID for logging
- `user_id` - Current user for authorization
- `tenant_id` - Multi-tenancy identifier
- `request_path` - Original request path
- `priority` - Request priority level

---

## 5. Span Attributes

### Setting Attributes

```python
span.set_attribute("key", "value")
span.set_attribute("user_id", 123)
span.set_attribute("email", "alice@example.com")
span.set_attribute("amount", 99.99)
span.set_attribute("success", True)
```

### Semantic Conventions

Use standard attribute names for consistency:

```python
# HTTP attributes
span.set_attribute("http.method", "POST")
span.set_attribute("http.status_code", 200)
span.set_attribute("http.target", "/orders")

# Database attributes
span.set_attribute("db.system", "sqlite")
span.set_attribute("db.operation", "INSERT")
span.set_attribute("db.statement", "INSERT INTO orders...")

# Service attributes
span.set_attribute("service.name", "order-service")
span.set_attribute("service.version", "1.0.0")
```

### Custom Business Attributes

```python
# Add business context
span.set_attribute("order.id", order_id)
span.set_attribute("order.total", total_price)
span.set_attribute("order.status", "pending")
span.set_attribute("product.category", "electronics")
```

---

## 6. Span Events

Events mark important moments within a span:

```python
with tracer.start_as_current_span("process_payment") as span:
    span.add_event("payment_initiated", {
        "amount": 100.00,
        "method": "credit_card"
    })
    
    # ... process payment ...
    
    span.add_event("payment_authorized", {
        "transaction_id": "txn_123",
        "auth_code": "AUTH123"
    })
    
    # ... send confirmation ...
    
    span.add_event("payment_confirmed", {
        "timestamp": datetime.utcnow().isoformat()
    })
```

---

## 7. Exception Handling in Spans

### Recording Exceptions

```python
with tracer.start_as_current_span("database_operation") as span:
    try:
        result = database.query(sql)
    except ValueError as e:
        span.record_exception(e)
        span.set_attribute("error", True)
        raise
```

### Custom Error Information

```python
except Exception as e:
    span.record_exception(e)
    span.set_attribute("error", True)
    span.set_attribute("error.kind", type(e).__name__)
    span.set_attribute("error.message", str(e))
    raise
```

---

## 8. Sampling

### Probability Sampling (head-based)

Decide at span creation time:

```python
from opentelemetry.sdk.trace.sampling import ProbabilitySampler

# Sample 10% of traces (9 out of 10 will be dropped)
sampler = ProbabilitySampler(rate=0.1)

trace_provider = TracerProvider(sampler=sampler)
```

### Sampler Rules

- **rate = 1.0** → All traces (only for development!)
- **rate = 0.1** → 10% of traces (production recommended)
- **rate = 0.01** → 1% of traces (high-volume systems)

### Tail-based Sampling (advanced)

Decide after collection (requires Jaeger sampling processor):

```yaml
# In Jaeger configuration
sampling:
  strategies:
    - service_name: "order-service"
      type: "probabilistic"
      param: 1.0  # Always sample order-service
    
    - service_name: "health-check"
      type: "probabilistic"
      param: 0.01  # Sample 1% of health checks
    
    - service_name: "*"
      type: "probabilistic"
      param: 0.1  # Default: 10%
```

---

## 9. Performance Considerations

### 1. Batch Span Processing

```python
# Good: batches spans before sending (default)
trace_provider.add_span_processor(
    BatchSpanProcessor(jaeger_exporter, schedule_delay_millis=5000)
)

# Avoid: sends immediately (high overhead)
trace_provider.add_span_processor(
    SimpleSpanProcessor(jaeger_exporter)
)
```

### 2. Sampling

```python
# Always sample in development
if environment == "development":
    sampler = ProbabilitySampler(rate=1.0)

# But not in production!
elif environment == "production":
    sampler = ProbabilitySampler(rate=0.1)
```

### 3. Cardinality Limits

Be careful with high-cardinality attributes:

```python
# ❌ BAD: Each user_id is unique (high cardinality)
for user_id in range(1000000):
    span.set_attribute("user_id", user_id)  # Creates 1M combinations!

# ✅ GOOD: Low-cardinality attributes
span.set_attribute("environment", "production")  # Few values
span.set_attribute("region", "us-east-1")       # Few values
```

---

## 10. Testing Spans Locally

### Enable Jaeger Exporter Logging

```python
import logging
logging.basicConfig(level=logging.DEBUG)

# Now you'll see debug logs when spans are created
```

### Export to Console (for testing)

```python
from opentelemetry.sdk.trace.export import ConsoleSpanExporter

trace_provider.add_span_processor(
    SimpleSpanProcessor(ConsoleSpanExporter())
)
```

### Print Trace Information

```python
from opentelemetry import trace

tracer = trace.get_tracer(__name__)

with tracer.start_as_current_span("test") as span:
    trace_id = span.get_span_context().trace_id
    span_id = span.get_span_context().span_id
    print(f"Trace ID: {trace_id}")
    print(f"Span ID: {span_id}")
```

---

## 11. Common Patterns

### Timeouts

```python
with tracer.start_as_current_span("external_call") as span:
    try:
        response = httpx.get(url, timeout=5.0)
    except httpx.TimeoutException as e:
        span.record_exception(e)
        span.set_attribute("error", True)
        span.set_attribute("timeout_seconds", 5.0)
        raise
```

### Retries

```python
for attempt in range(3):
    with tracer.start_as_current_span("call_with_retry") as span:
        span.set_attribute("attempt", attempt + 1)
        try:
            result = risky_operation()
            span.set_attribute("success", True)
            break
        except Exception as e:
            span.record_exception(e)
            if attempt == 2:
                raise
            else:
                span.set_attribute("retry", True)
```

### Caching

```python
with tracer.start_as_current_span("get_user") as span:
    if user_id in cache:
        span.set_attribute("cache_hit", True)
        return cache[user_id]
    else:
        span.set_attribute("cache_hit", False)
        user = database.get_user(user_id)
        cache[user_id] = user
        return user
```

---

## Summary

**Key Points:**

1. **Initialize** Jaeger exporter and trace provider on startup
2. **Auto-instrument** FastAPI, database, HTTP client
3. **Create spans** manually for business logic
4. **Set attributes** for debugging and analysis
5. **Propagate context** automatically via HTTP headers
6. **Use baggage** for cross-cutting concerns
7. **Record exceptions** for error tracking
8. **Sample intelligently** (100% dev, 10% prod)
9. **Batch spans** for performance
10. **Test locally** with console exporter

---

## Next Steps

- Read `JAEGER_SETUP.md` for deployment details
- Check `QUERIES.md` for querying traces
- Review service code in `services/*/app.py` for examples
