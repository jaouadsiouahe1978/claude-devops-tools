# 🔗 Linkerd Service Mesh - Advanced Microservices Management

**Level:** Expert | **Duration:** 1 day (6-8 hours) | **Date:** August 10, 2026

## 📋 Project Overview

Build a **lightweight service mesh** using Linkerd to manage microservices communication, traffic policies, and observability.

### What You'll Learn

✅ **Service Mesh Architecture** - Sidecar proxy patterns  
✅ **Linkerd Installation** - Deploy & configure control plane  
✅ **Traffic Management** - Policy-based routing & canary deployments  
✅ **Security** - Automatic mTLS between services  
✅ **Observability** - Built-in metrics & request tracing  
✅ **Reliability** - Retries, timeouts, circuit breaking  

## 🚀 Quick Start

```bash
# Navigate to project
cd /home/user/claude-devops-tools/projects/2026-08-10_linkerd-service-mesh

# Install everything
make install-linkerd
make create-namespace
make deploy-services

# Verify
make verify

# Open dashboard
make open-dashboard
```

## 📊 Architecture

```
Kubernetes Cluster
├── Linkerd Control Plane (linkerd namespace)
│   ├── Controller
│   ├── Identity & Certificate Management
│   ├── Proxy Injector
│   ├── Dashboard
│   ├── Prometheus
│   └── Grafana
│
└── Application Namespace (services namespace)
    ├── Frontend (Nginx x2 + Linkerd proxies)
    │   ├─ Auto-injected mTLS
    │   └─ Automatic service discovery
    │
    ├── Backend (FastAPI x3 + Linkerd proxies)
    │   ├─ Request routing
    │   └─ Circuit breaking
    │
    └── Worker (FastAPI x2 + Linkerd proxies)
        ├─ Async task processing
        └─ Auto-scaled
```

## 🛠️ Makefile Commands

```bash
# Installation
make install-linkerd        # Install control plane
make create-namespace       # Create app namespace
make deploy-services        # Deploy applications

# Verification
make verify                 # Check all components
make check-mTLS            # Verify security
make check-injection       # Verify proxy injection

# Observability
make open-dashboard        # Linkerd UI
make open-prometheus       # Metrics database
make test-traffic          # Generate traffic
make load-test            # Sustained traffic

# Management
make deploy-canary        # Deploy canary version
make deploy-policies      # Deploy traffic policies
make logs                 # View application logs
make clean                # Remove everything
```

## 📈 Key Metrics

| Metric | Value | Notes |
|--------|-------|-------|
| Control Plane Overhead | ~256MB memory | Lightweight vs Istio (1GB+) |
| Proxy Latency | ~5μs | Negligible impact |
| Proxy Memory | ~10MB per pod | Minimal resource usage |
| mTLS Encryption | Automatic | Zero configuration |
| Certificate Rotation | 24h | Automatic renewal |

## 🔒 Security Features

- **Automatic mTLS** - All service-to-service encrypted
- **Pod Identity** - Each pod has unique certificate
- **Network Policies** - Layer 3/4 access control
- **Non-root** - Pods run as non-root user
- **Read-only FS** - Where applicable

## 📊 Observability

- **Live Dashboard** - Service topology & metrics
- **Prometheus** - Metrics collection & storage
- **Grafana** - Pre-configured dashboards
- **Request Tracing** - Integration with Jaeger
- **Health Checks** - Automatic pod health monitoring

## 🎓 Learning Outcomes

After completing this project, you'll understand:

- Service mesh architecture & benefits
- Linkerd's lightweight approach vs alternatives
- Automatic proxy injection
- Traffic policies & service profiles
- mTLS implementation at scale
- Canary deployments safely
- Observability integration

## 📚 Documentation

- `README.md` - This file (overview)
- `SETUP.md` - Step-by-step setup guide
- `manifests/` - Kubernetes YAML manifests
- `scripts/` - Automation & testing tools

## 🔗 Related Projects

- `2026-08-09_kubernetes-statefulset-postgres` - K8s state management
- `2026-08-07_jaeger-distributed-tracing` - Distributed tracing
- `2026-08-05_github-actions-cicd` - CI/CD pipelines

## ✅ Production Readiness

✓ Helm-ready manifests
✓ Security policies enforced
✓ Health checks configured
✓ Pod disruption budgets
✓ Horizontal pod autoscaling
✓ Comprehensive monitoring
✓ Disaster recovery patterns

---

**Level:** Expert | **Difficulty:** ⭐⭐⭐⭐ | **Time:** 6-8 hours

*Part of Jaouad's DevOps/SRE Formation - Day 96/180*
