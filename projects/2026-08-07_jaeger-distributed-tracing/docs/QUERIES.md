# Jaeger Queries & Analysis Guide

## Table of Contents

1. [Jaeger UI Navigation](#jaeger-ui-navigation)
2. [API Queries](#api-queries)
3. [Advanced Filtering](#advanced-filtering)
4. [Performance Analysis](#performance-analysis)
5. [Debugging Strategies](#debugging-strategies)
6. [Example Scenarios](#example-scenarios)

---

## Jaeger UI Navigation

### Access Jaeger UI

```bash
# Open in browser
open http://localhost:16686

# Or via make command
make open-jaeger
```

### Main Screen

```
┌─────────────────────────────────────────────────┐
│  Service: [order-service ▼]                    │
│  Operation: [POST /orders ▼]                   │
│  Tags: [key=value]                             │
│  Min Duration: [0]                             │
│  Max Duration: [0]                             │
│  Limit Results: [20]  [Find Traces]            │
└─────────────────────────────────────────────────┘
        ↓
┌──────────────────────────────────────────┐
│ Trace Results                            │
├──────────────────────────────────────────┤
│ ✓ trace_123... 2.5s  8 spans  order-svc │
│ ✓ trace_124... 1.2s  8 spans  order-svc │
│ ✓ trace_125... 3.1s  8 spans  order-svc │
└──────────────────────────────────────────┘
        ↓
    [Click trace]
        ↓
┌──────────────────────────────────────────┐
│ Trace Detail & Timeline                  │
├──────────────────────────────────────────┤
│ ┌─ order-service POST /orders [2.5s]    │
│ │  ├─ call_user_service [400ms]         │
│ │  ├─ call_product_service [350ms]      │
│ │  ├─ reserve_product_stock [300ms]     │
│ │  └─ save_order_to_db [700ms]          │
│ └─ [Total: 2.5s]                        │
└──────────────────────────────────────────┘
```

---

## API Queries

### 1. List All Services

```bash
curl http://localhost:16686/api/services | jq .data

# Response
{
  "data": [
    "order-service",
    "product-service",
    "user-service"
  ]
}
```

### 2. Get Operations for a Service

```bash
curl "http://localhost:16686/api/services/order-service/operations" | jq .data

# Response
{
  "data": [
    "POST /orders",
    "GET /orders",
    "GET /orders/{order_id}"
  ]
}
```

### 3. Query Traces

```bash
# Get recent traces
curl "http://localhost:16686/api/traces?service=order-service&limit=10" | jq .

# With specific operation
curl "http://localhost:16686/api/traces?service=order-service&operation=POST%20%2Forders&limit=5"

# Filter by duration (microseconds)
curl "http://localhost:16686/api/traces?service=order-service&minDuration=1000000"  # >= 1 second

# Filter by tags
curl "http://localhost:16686/api/traces?service=order-service&tags=error%3Dtrue"
```

### 4. Get Single Trace

```bash
# Get trace by ID (found in trace list)
TRACE_ID="a1b2c3d4e5f6g7h8"
curl "http://localhost:16686/api/traces/${TRACE_ID}" | jq .
```

### 5. Get Trace Statistics

```bash
# Service dependency graph
curl "http://localhost:16686/api/services" | jq .

# Error rates
curl "http://localhost:16686/api/traces?service=order-service&tags=error%3Dtrue"
```

---

## Advanced Filtering

### Filter by Tags

Tags are key-value pairs in spans:

```bash
# Find error traces
curl "http://localhost:16686/api/traces?service=order-service&tags=error%3Dtrue"

# Find by status code
curl "http://localhost:16686/api/traces?service=order-service&tags=http.status_code%3D500"

# Find by user
curl "http://localhost:16686/api/traces?service=order-service&tags=user_id%3D123"

# Multiple tags (AND logic)
curl "http://localhost:16686/api/traces?service=order-service&tags=error%3Dtrue&tags=http.status_code%3D500"
```

### Filter by Duration

```bash
# Traces slower than 1 second
curl "http://localhost:16686/api/traces?service=order-service&minDuration=1000000"

# Traces faster than 500ms
curl "http://localhost:16686/api/traces?service=order-service&maxDuration=500000"

# Between 500ms and 2 seconds
curl "http://localhost:16686/api/traces?service=order-service&minDuration=500000&maxDuration=2000000"
```

### Filter by Timestamp

```bash
# Last 1 hour (in microseconds since epoch)
curl "http://localhost:16686/api/traces?service=order-service&start=$(expr $(date +%s) - 3600)000000"

# Last 24 hours
curl "http://localhost:16686/api/traces?service=order-service&start=$(expr $(date +%s) - 86400)000000"
```

---

## Performance Analysis

### 1. Identify Slow Operations

**Via UI:**
1. Select Service → Operation
2. Click "Find Traces"
3. Sort by duration (click column header)
4. Examine slowest traces

**Via API:**
```bash
# Get traces sorted by duration
curl "http://localhost:16686/api/traces?service=order-service&limit=20" | \
  jq '.data | sort_by(.duration) | reverse | .[0:5]'
```

### 2. Find Bottleneck Services

**In Trace Detail:**
1. Look at timeline view
2. Find longest spans
3. Check which service they're from

**Common bottlenecks:**
- Database queries (look for `save_order_to_db` spans)
- External service calls (look for `call_*_service` spans)
- Network latency (look for HTTP spans with high duration)

### 3. Service Dependencies

Look at trace timeline to understand call chain:

```
order-service (top-level): 2500ms total
├─ FastAPI middleware: 10ms
├─ call_user_service: 400ms
│  └─ HTTP request + response
├─ call_product_service: 350ms
│  └─ HTTP request + response
├─ reserve_product_stock: 300ms
│  └─ HTTP request
├─ save_order_to_db: 700ms
│  └─ SQLite INSERT query
└─ FastAPI response: 5ms
```

**Insight:** Database query (700ms) is the biggest bottleneck!

---

## Debugging Strategies

### Strategy 1: Find Error Traces

```bash
# Get all error traces in last 1 hour
curl "http://localhost:16686/api/traces?service=order-service&tags=error%3Dtrue&limit=50" | \
  jq '.data[] | {
    trace_id: .traceID,
    duration: .duration,
    services: [.spans[].process.serviceName] | unique,
    errors: [.spans[] | select(.tags[]? | .key == "error" and .value == true) | .operationName]
  }'
```

### Strategy 2: Compare Slow vs Fast Traces

```bash
# Slow traces (>2s)
SLOW=$(curl -s "http://localhost:16686/api/traces?service=order-service&minDuration=2000000&limit=1" | jq '.data[0]')

# Fast traces (<500ms)
FAST=$(curl -s "http://localhost:16686/api/traces?service=order-service&maxDuration=500000&limit=1" | jq '.data[0]')

# Compare spans
echo "Slow trace: $(echo $SLOW | jq '.spans | length') spans"
echo "Fast trace: $(echo $FAST | jq '.spans | length') spans"
```

### Strategy 3: Track Request Through Services

1. In Jaeger UI, open a trace
2. Look for trace ID in header (e.g., `a1b2c3d4e5f6g7h8`)
3. Look at span tags for `http.target` (original request path)
4. Follow child spans to child services
5. Each child service should have same trace ID in its logs

```bash
# Check logs for trace ID
TRACE_ID="a1b2c3d4e5f6g7h8"
docker-compose logs order-service | grep $TRACE_ID
docker-compose logs user-service | grep $TRACE_ID
docker-compose logs product-service | grep $TRACE_ID
```

---

## Example Scenarios

### Scenario 1: Order Creation is Slow

**Problem:** Users report slow order creation

**Solution:**

```bash
# 1. Find slow order traces
curl -s "http://localhost:16686/api/traces?service=order-service&operation=POST%20%2Forders&minDuration=2000000&limit=10" | jq .

# 2. Get a slow trace
TRACE_ID=$(curl -s "..." | jq -r '.data[0].traceID')

# 3. Examine the trace
curl -s "http://localhost:16686/api/traces/$TRACE_ID" | jq '.data.spans[] | {
  operation: .operationName,
  duration: .duration,
  service: .process.serviceName,
  tags: [.tags[] | select(.key | contains("error") or contains("status")) | {(.key): .value}]
}' | sort_by(.duration) | reverse

# 4. Identify slowest span
# → "save_order_to_db" takes 700ms
# → Recommendation: Add database index or use connection pooling
```

### Scenario 2: Errors in Order Service

**Problem:** Some orders fail to create

**Solution:**

```bash
# 1. Find error traces
curl -s "http://localhost:16686/api/traces?service=order-service&tags=error%3Dtrue&limit=20" | \
  jq '.data[] | {
    trace_id: .traceID,
    error_span: [.spans[] | select(.tags[]? | .key == "error") | .operationName][0],
    duration: .duration
  }'

# 2. Get full trace details
TRACE_ID=$(curl -s "http://localhost:16686/api/traces?service=order-service&tags=error%3Dtrue&limit=1" | jq -r '.data[0].traceID')

curl -s "http://localhost:16686/api/traces/$TRACE_ID" | jq '.data.spans[] | {
  span: .operationName,
  status: [.tags[] | select(.key == "error") | .value][0],
  message: [.tags[] | select(.key | contains("message")) | .value][0],
  exception: [.logs[] | select(.fields[] | .key == "exception.type")][0]
}'

# 3. Common causes:
# - User not found: Check user-service status
# - Product not found: Check product-service status
# - Insufficient stock: See reserve_product response
```

### Scenario 3: Service A Can't Reach Service B

**Problem:** order-service can't call user-service

**Solution:**

```bash
# 1. Check for failed spans in order-service
curl -s "http://localhost:16686/api/traces?service=order-service&tags=error%3Dtrue&limit=20" | \
  jq '.data[] | .spans[] | select(.operationName | contains("user")) | {
    operation: .operationName,
    error: [.tags[] | select(.key == "error") | .value][0],
    http_status: [.tags[] | select(.key == "http.status_code") | .value][0]
  }'

# 2. Check user-service health
curl -s http://localhost:8001/health | jq .

# 3. Check docker network
docker network inspect devops

# 4. Test connectivity from order-service container
docker-compose exec order-service curl http://user-service:8001/health
```

---

## Performance Tuning Based on Traces

### Issue: High Latency on Database Operations

**Trace shows:**
```
save_order_to_db: 700ms (too slow!)
```

**Analysis:**
```bash
curl -s "http://localhost:16686/api/traces/..../..." | \
  jq '.data.spans[] | select(.operationName == "save_order_to_db") | {
    duration: .duration,
    db_statement: [.tags[] | select(.key | contains("statement")) | .value][0]
  }'
```

**Solutions:**
1. Add database index: `CREATE INDEX idx_orders_user_id ON orders(user_id);`
2. Use bulk inserts instead of individual inserts
3. Enable connection pooling
4. Check for locks: `sqlite3 /tmp/orders.db "PRAGMA integrity_check;"`

### Issue: High Latency on External Calls

**Trace shows:**
```
call_user_service: 400ms
├─ HTTP request/response: 350ms
├─ DNS lookup: 20ms
└─ TLS negotiation: 30ms
```

**Solutions:**
1. Implement connection pooling: `httpx.AsyncClient()` reuse
2. Add timeout: `.get(url, timeout=5.0)`
3. Cache user data: Use Redis
4. Use circuit breaker pattern: Fail fast if service is down

### Issue: High Error Rate

**Trace shows:**
```
Multiple traces with error=true
Error messages: "User not found", "Product out of stock"
```

**Solutions:**
1. **User not found:** Pre-validate user IDs in request
2. **Product out of stock:** Check stock before reserve attempt
3. **Timeout:** Increase timeout or add retry logic
4. **Network:** Check service connectivity

---

## Monitoring Dashboard Queries

### For Prometheus

```promql
# Average request duration by service
histogram_quantile(0.95, rate(rpc_duration_seconds_bucket[5m]))

# Request error rate
rate(rpc_failed_total[5m])

# Traces per minute
rate(jaeger_spans_received_total[1m])
```

### For Grafana

Create a dashboard with:
1. **Service Latency:** P99 duration by service
2. **Error Rate:** Errors/total by service
3. **Dependency Graph:** Service call relationships
4. **Span Distribution:** Spans by operation

---

## Common Queries Reference

```bash
# Service list
curl -s http://localhost:16686/api/services | jq .

# Recent traces
curl -s "http://localhost:16686/api/traces?service=order-service&limit=20" | jq .

# Error traces
curl -s "http://localhost:16686/api/traces?service=order-service&tags=error%3Dtrue" | jq .

# Slow traces
curl -s "http://localhost:16686/api/traces?service=order-service&minDuration=1000000" | jq .

# By operation
curl -s "http://localhost:16686/api/traces?service=user-service&operation=GET%20%2Fusers" | jq .
```

---

## Summary

**Key Analysis Techniques:**

1. **Find** slow/error traces via UI or API
2. **Examine** trace timeline to find bottlenecks
3. **Compare** slow vs fast traces to identify differences
4. **Correlate** with service logs using trace IDs
5. **Iterate** - fix, test, measure improvement in traces

**Always remember:**
- Traces show WHERE time is spent
- Metrics show WHAT happened
- Logs show WHY it happened

Combine all three for complete observability!
