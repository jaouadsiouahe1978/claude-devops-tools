# 🔍 Jaeger Distributed Tracing Setup

**Formation DevOps/SRE - Day 95**  
**Date:** August 7, 2026  
**Level:** Advanced → Expert  
**Learning Goal:** Implement end-to-end distributed tracing across microservices

---

## 📋 Project Overview

This project demonstrates a **production-ready Jaeger distributed tracing setup** with a complete microservices architecture. You'll learn how to instrument applications, correlate requests across services, and identify performance bottlenecks in real-time.

### What You'll Build

```
┌─────────────────────────────────────────────────────────────┐
│                    Client Browser / API                      │
└────────────────────┬────────────────────────────────────────┘
                     │
         ┌───────────┴───────────┐
         │                       │
    ┌────▼─────┐           ┌────▼──────┐
    │  API     │           │  Web      │
    │ Gateway  │           │ Frontend  │
    └────┬─────┘           └────┬──────┘
         │                       │
    ┌────┴──────────────────────┴─────┐
    │                                  │
┌───▼──────┐  ┌──────────┐  ┌────────▼──┐
│ User     │  │ Product  │  │ Order     │
│ Service  │  │ Service  │  │ Service   │
└───┬──────┘  └────┬─────┘  └────┬──────┘
    │              │              │
    └──────────┬───┴──────┬───────┘
               │          │
         ┌─────▼──┐  ┌────▼────┐
         │Database│  │ Cache    │
         └────────┘  └──────────┘
               │
         ┌─────▼──────────────┐
         │  Jaeger Collector  │
         │  + Elasticsearch   │
         └─────┬──────────────┘
               │
    ┌──────────▼───────────┐
    │  Jaeger UI / Query   │
    │  :6831 (agent)       │
    │  :14268 (collector)  │
    │  :16686 (UI)         │
    └──────────────────────┘
```

### Key Concepts

1. **Spans** - Individual operations in a trace
2. **Traces** - Complete request journeys across services
3. **Correlation IDs** - Track requests end-to-end
4. **Sampling** - Intelligent trace collection
5. **Baggage** - Propagate metadata across spans

---

## 🎯 Objectives

- ✅ Set up Jaeger backend (All-in-One for development)
- ✅ Instrument 3 microservices with OpenTelemetry
- ✅ Configure trace propagation (W3C Trace Context)
- ✅ Implement custom spans and baggage
- ✅ Query traces via Jaeger UI
- ✅ Export traces to Elasticsearch for long-term storage
- ✅ Monitor trace metrics in Prometheus/Grafana
- ✅ Perform load testing and analyze traces

---

## 🔧 Technologies

| Component | Version | Purpose |
|-----------|---------|---------|
| **Jaeger** | 1.50.0 | Distributed Tracing System |
| **OpenTelemetry** | 1.20+ | Instrumentation Library |
| **Python/FastAPI** | 3.11/0.104 | API Services |
| **Elasticsearch** | 8.10 | Trace Storage (persistent) |
| **Prometheus** | 2.45 | Metrics Collection |
| **Docker Compose** | v3.9 | Orchestration |

---

## 📦 Project Structure

```
2026-08-07_jaeger-distributed-tracing/
├── README.md                          # This file
├── docker-compose.yml                 # Full stack (Jaeger + services + ELK)
├── Makefile                           # Automation commands
│
├── services/
│   ├── user-service/
│   │   ├── app.py                    # FastAPI User Service
│   │   ├── requirements.txt          # Python dependencies
│   │   └── Dockerfile                # Container config
│   │
│   ├── product-service/
│   │   ├── app.py                    # FastAPI Product Service
│   │   ├── requirements.txt
│   │   └── Dockerfile
│   │
│   └── order-service/
│       ├── app.py                    # FastAPI Order Service
│       ├── requirements.txt
│       └── Dockerfile
│
├── client/
│   ├── load_test.py                  # Locust load testing
│   ├── trace_client.py               # HTTP client for trace testing
│   └── requirements.txt
│
├── config/
│   ├── jaeger-config.json            # Jaeger configuration
│   ├── elasticsearch.yml             # ES configuration
│   └── prometheus.yml                # Prometheus scrape config
│
└── docs/
    ├── JAEGER_SETUP.md               # Installation & setup guide
    ├── INSTRUMENTATION.md            # How to instrument code
    ├── QUERIES.md                    # Jaeger query examples
    └── TROUBLESHOOTING.md            # Common issues & solutions
```

---

## 🚀 Quick Start (5 minutes)

### 1️⃣ Prerequisites

```bash
# Check system requirements
docker --version          # >= 20.10
docker-compose --version  # >= 1.29
python3 --version         # >= 3.9
```

### 2️⃣ Clone & Navigate

```bash
cd /home/user/claude-devops-tools
cd projects/2026-08-07_jaeger-distributed-tracing
```

### 3️⃣ Start Services

```bash
# Start entire stack (Jaeger, services, Elasticsearch, Prometheus)
make up

# Watch logs
make logs

# Verify health
make health
```

### 4️⃣ Generate Traces

```bash
# Terminal 1: Start load testing (generates traces)
make load-test

# Terminal 2: View Jaeger UI
open http://localhost:16686

# Terminal 3: Monitor Prometheus metrics
open http://localhost:9090

# Terminal 4: Check Elasticsearch
curl http://localhost:9200/_cat/indices
```

### 5️⃣ Explore Traces

In Jaeger UI (http://localhost:16686):
1. Select service: "order-service"
2. Look for operation: "POST /orders"
3. Click on a trace to see the full journey:
   - API Gateway → Order Service → User Service → Product Service → Database
   - View spans, latencies, errors, and custom tags

### 6️⃣ Stop Services

```bash
make down
make clean
```

---

## 📖 Learning Path

### Phase 1: Foundation (20 min)
- [ ] Read: Distributed tracing concepts
- [ ] Read: Jaeger architecture (agent, collector, query)
- [ ] Read: OpenTelemetry basics

### Phase 2: Setup (15 min)
- [ ] Deploy Jaeger all-in-one
- [ ] Verify connectivity
- [ ] Access Jaeger UI

### Phase 3: Instrumentation (30 min)
- [ ] Instrument user-service with OpenTelemetry
- [ ] Add custom spans
- [ ] Test trace propagation

### Phase 4: Integration (25 min)
- [ ] Instrument order-service
- [ ] Instrument product-service
- [ ] Configure trace context propagation

### Phase 5: Analysis (20 min)
- [ ] Generate traces via load test
- [ ] Query traces by service, operation, tags
- [ ] Identify slow spans and bottlenecks
- [ ] Export traces to Elasticsearch

### Phase 6: Monitoring (15 min)
- [ ] Export Jaeger metrics to Prometheus
- [ ] Create Grafana dashboards
- [ ] Set up alerts on trace latency

**Total Estimated Time:** 2-3 hours for complete setup + experimentation

---

## 🔑 Key Commands

### Docker & Compose

```bash
# Start all services
docker-compose up -d

# View logs from specific service
docker-compose logs -f jaeger

# Stop all services
docker-compose down

# Remove volumes (clean data)
docker-compose down -v
```

### Service Health

```bash
# Check if Jaeger is responding
curl -s http://localhost:6831 && echo "Agent OK" || echo "Agent FAILED"
curl -s http://localhost:14268/api/traces && echo "Collector OK" || echo "Collector FAILED"

# Check services
curl http://localhost:8001/health  # user-service
curl http://localhost:8002/health  # product-service
curl http://localhost:8003/health  # order-service

# Jaeger UI
curl http://localhost:16686
```

### Generate Test Data

```bash
# Send test requests
python3 client/trace_client.py

# Load test (100 requests, 5 concurrent)
locust -f client/load_test.py \
  --host=http://localhost:8003 \
  --users=5 \
  --spawn-rate=2 \
  --run-time=60s
```

### Query Traces (via Jaeger API)

```bash
# Get services
curl http://localhost:16686/api/services

# Get operations for a service
curl "http://localhost:16686/api/services/user-service/operations"

# Query traces
curl "http://localhost:16686/api/traces?service=order-service&limit=20"

# Get trace by ID
curl "http://localhost:16686/api/traces/TRACE_ID"
```

---

## 📊 What Gets Instrumented

### User Service
```python
# Automatic spans:
- POST /users          (create user)
- GET /users/{id}      (get user)
- DATABASE query       (fetch from DB)
- CACHE lookup         (Redis)

# Custom tags:
- user_id
- email
- db_latency_ms
- cache_hit (bool)
```

### Product Service
```python
# Automatic spans:
- GET /products        (list)
- GET /products/{id}   (details)
- DATABASE query       (fetch from DB)
- CACHE lookup

# Custom tags:
- product_id
- category
- stock_level
- cache_hit
```

### Order Service
```python
# Automatic spans:
- POST /orders                           (create order)
  └── Call /users/{user_id}              (dependency)
  └── Call /products/{product_id}        (dependency)
  └── DATABASE transaction               (create order record)

# Custom baggage:
- correlation_id
- user_id
- order_id

# Custom tags:
- order_status
- payment_method
- total_amount
- fulfillment_status
```

---

## 🎓 What You'll Learn

### Observability
- End-to-end request tracking
- Latency analysis across services
- Dependency mapping (service graph)
- Error and exception tracking

### Instrumentation
- OpenTelemetry Python SDK
- Auto-instrumentation (FastAPI)
- Manual span creation
- Custom attributes and tags

### Distributed Systems
- Trace context propagation (W3C standard)
- Correlation IDs
- Baggage for cross-cutting concerns
- Sampling strategies (head-based, tail-based)

### Performance Tuning
- Identify bottleneck services
- SQL query optimization (from trace duration)
- Cache effectiveness analysis
- Network latency measurement

### Troubleshooting
- Trace correlation during incidents
- Root cause analysis
- Dependency chain debugging
- Error propagation tracking

---

## 📈 Example: Trace Analysis Workflow

### Scenario: Order creation is slow

1. **Open Jaeger UI** → Select `order-service` → Sort by latency
2. **Inspect trace** for "POST /orders" (e.g., 2500ms total)
3. **See span breakdown:**
   ```
   order-service.validate_request     50ms   ✅
   order-service.get_user             400ms  ⚠️  (network + db)
   order-service.get_product           350ms  ⚠️  (network + db)
   order-service.create_order_db       700ms  ⚠️  (slow insert)
   order-service.send_confirmation     400ms  ⚠️  (email service)
   order-service.response              10ms   ✅
   ```
4. **Drill down:**
   - Click "get_user" span → see database query time
   - Check if cache was hit (look at baggage)
   - Compare against baseline traces
5. **Take action:**
   - Add Redis caching for users
   - Implement async email sending
   - Add database index on order creation query

---

## 🔍 Advanced Topics

### Sampling Strategies
```python
# Head-based sampling (decide at ingestion)
sampler = ProbabilitySampler(rate=0.1)  # Sample 10% of traces

# Tail-based sampling (decide after collection)
# Keep errors, high-latency traces, specific services
```

### Trace Propagation
```python
# W3C Trace Context header format
traceparent: 00-trace_id-span_id-flags
# Example:
traceparent: 00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01
```

### Custom Instrumentation
```python
from opentelemetry import trace

tracer = trace.get_tracer(__name__)

with tracer.start_as_current_span("my_operation") as span:
    span.set_attribute("user_id", 123)
    span.add_event("cache_hit", {"key": "user:123"})
    # your code here
```

---

## 🐛 Troubleshooting

### Traces not appearing in Jaeger UI
1. Check Jaeger collector is running: `curl http://localhost:14268/api/traces`
2. Check service is sending traces: `docker logs user-service | grep trace`
3. Verify JAEGER_AGENT_HOST=jaeger:6831 env var
4. Check network connectivity: `docker network ls`

### High memory usage
- Reduce sampling rate in services
- Lower Jaeger retention period
- Archive old spans to Elasticsearch

### Slow UI queries
- Index traces in Elasticsearch
- Add span indexes for common queries
- Implement span filtering

See `docs/TROUBLESHOOTING.md` for more solutions.

---

## 📚 References

### Documentation
- [Jaeger Official Docs](https://www.jaegertracing.io/docs/)
- [OpenTelemetry Python](https://opentelemetry.io/docs/instrumentation/python/)
- [Distributed Tracing Guide](https://opentelemetry.io/docs/concepts/signals/traces/)
- [W3C Trace Context](https://w3c.github.io/trace-context/)

### Related DevOps Tools
- **Distributed Tracing:** Jaeger, Zipkin, DataDog
- **Metrics:** Prometheus, Grafana
- **Logs:** ELK, Loki, Splunk
- **Infrastructure:** Docker, Kubernetes, Terraform

---

## ✅ Completion Checklist

- [ ] Docker Compose stack running (8 containers)
- [ ] All 3 services responding to health checks
- [ ] Jaeger UI accessible and showing services
- [ ] At least 1 complete trace visible in UI
- [ ] Load test generating multiple traces
- [ ] Can identify slow spans in a trace
- [ ] Elasticsearch receiving and storing traces
- [ ] Prometheus scraping trace metrics
- [ ] Basic Grafana dashboard created
- [ ] README documentation complete
- [ ] All code committed to GitHub

---

## 📝 Implementation Notes

### Current Status
- ✅ Project structure created
- ✅ Docker Compose configured
- ✅ 3 microservices scaffolded
- ✅ OpenTelemetry integrated
- ⏳ Load testing client ready
- ⏳ Elasticsearch integration configured
- ⏳ Prometheus metrics export ready

### Next Steps
1. Run `make up` to start all services
2. Generate traces with `make load-test`
3. Explore Jaeger UI at http://localhost:16686
4. Modify services to add custom instrumentation
5. Create Grafana dashboards for trace metrics
6. Document findings and learnings

---

## 👤 For Jaouad

**This project will teach you:**
- How major platforms (Google, Netflix, Uber) track requests
- Why Netflix uses Distributed Tracing for chaos engineering
- How to debug production issues in microservices
- Performance optimization based on trace data

**Time Investment:** 2-3 hours (hands-on)  
**Difficulty:** Advanced → Expert  
**Real-world Application:** Essential for production monitoring

---

**Created:** August 7, 2026 (Day 95)  
**Email:** jsinfo38@gmail.com  
**Repository:** https://github.com/jaouadsiouahe1978/claude-devops-tools

