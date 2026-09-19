# Kubernetes ConfigMap & Secret Management - Complete Guide

## Table of Contents
1. [Project Overview](#project-overview)
2. [Prerequisites](#prerequisites)
3. [Architecture](#architecture)
4. [Setup Instructions](#setup-instructions)
5. [Deployment](#deployment)
6. [Usage Examples](#usage-examples)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)

## Project Overview

This project demonstrates professional Kubernetes configuration management patterns for multi-environment deployments (dev, staging, prod). It covers:

- **ConfigMaps**: Managing non-sensitive configuration data
- **Secrets**: Securely handling sensitive information
- **Kustomize**: Creating DRY, reusable Kubernetes deployments
- **RBAC**: Role-based access control for secrets
- **Environment Separation**: Namespace-based environment isolation
- **Secret Rotation**: Safe credential updates with zero downtime

## Prerequisites

### Required Tools
```bash
# Check Kubernetes version (1.24+)
kubectl version --client

# Check kustomize version
kustomize version

# Docker (for building images)
docker --version
```

### Installation (macOS with Homebrew)
```bash
# Install Kubernetes tools
brew install kubectl kustomize

# Install Docker Desktop for local Kubernetes
brew install --cask docker
```

### Kubernetes Cluster Options
- **Docker Desktop**: Built-in Kubernetes (enable in settings)
- **Minikube**: `brew install minikube && minikube start`
- **Kind**: `brew install kind && kind create cluster`
- **Cloud**: GKE, EKS, AKS, or any managed Kubernetes service

## Architecture

### Directory Structure
```
k8s-config-demo/
├── base/                          # Base configuration
│   ├── deployment.yaml           # Deployment manifest
│   ├── service.yaml             # Service manifest
│   ├── serviceaccount.yaml       # RBAC configuration
│   └── kustomization.yaml        # Base kustomization
├── overlays/                      # Environment-specific overrides
│   ├── dev/
│   │   ├── configmap.yaml        # Dev config (verbose, debug enabled)
│   │   ├── secrets.yaml          # Dev secrets (weak passwords)
│   │   ├── namespace.yaml        # Dev namespace
│   │   └── kustomization.yaml    # Dev overlay
│   ├── staging/
│   │   ├── configmap.yaml        # Staging config
│   │   ├── secrets.yaml          # Staging secrets
│   │   ├── namespace.yaml
│   │   └── kustomization.yaml
│   └── prod/
│       ├── configmap.yaml        # Prod config (optimized)
│       ├── secrets.yaml          # Prod secrets (strong passwords)
│       ├── namespace.yaml
│       └── kustomization.yaml
├── app/                          # Application code
│   ├── app.py                   # Flask application
│   ├── Dockerfile               # Container image
│   └── requirements.txt          # Python dependencies
└── scripts/                      # Automation scripts
    ├── deploy.sh               # Deployment automation
    ├── verify.sh               # Verification checks
    └── rotate-secrets.sh       # Secret rotation tool
```

### Configuration Hierarchy

```
Base Configuration (common to all)
        ↓
Environment Overlays (dev/staging/prod)
        ↓
ConfigMaps & Secrets (environment-specific)
        ↓
Pods (with injected configuration)
```

## Setup Instructions

### 1. Prepare Your Local Cluster

```bash
# Ensure cluster is running
kubectl cluster-info

# Verify Kubernetes version
kubectl version

# Check available resources
kubectl top nodes
```

### 2. Build Application Docker Image

```bash
# Navigate to project directory
cd projects/2026-09-19_k8s-configmap-secrets

# Build Docker image
docker build -t config-demo:latest ./app

# Verify image
docker images | grep config-demo

# If using Minikube, load image into cluster
minikube image load config-demo:latest

# If using Kind
kind load docker-image config-demo:latest
```

### 3. Make Scripts Executable

```bash
chmod +x scripts/deploy.sh
chmod +x scripts/verify.sh
chmod +x scripts/rotate-secrets.sh
```

## Deployment

### Deploy All Environments

```bash
# Deploy all three environments
./scripts/deploy.sh all

# Or manually
kubectl apply -k overlays/dev
kubectl apply -k overlays/staging
kubectl apply -k overlays/prod
```

### Deploy Specific Environment

```bash
# Development only
./scripts/deploy.sh deploy dev

# Staging only
./scripts/deploy.sh deploy staging

# Production only
./scripts/deploy.sh deploy prod
```

### Verify Deployment

```bash
# Run automated verification
./scripts/verify.sh

# Manual verification
kubectl get all -n dev
kubectl get all -n staging
kubectl get all -n prod

# Check ConfigMaps
kubectl get configmaps -n dev
kubectl get configmap app-config -n dev -o yaml

# Check Secrets (note: values are base64 encoded)
kubectl get secrets -n prod
kubectl get secret app-secrets -n prod -o yaml
```

## Usage Examples

### View Configuration in Running Pod

```bash
# Get pod name
POD=$(kubectl get pods -n dev -l app=config-demo -o jsonpath='{.items[0].metadata.name}')

# View all environment variables
kubectl exec -it $POD -n dev -- env | sort

# View specific configuration
kubectl exec -it $POD -n dev -- env | grep -E "DB_|API_|LOG_"
```

### Test Application Endpoints

```bash
# Port forward to dev service
kubectl port-forward -n dev svc/config-demo 8080:5000 &

# Get health status
curl http://localhost:8080/health

# View configuration
curl http://localhost:8080/config

# Get detailed info
curl http://localhost:8080/info | jq .

# Kill port forward
pkill -f "port-forward"
```

### Compare Configurations Across Environments

```bash
# Development
kubectl get configmap app-config -n dev -o jsonpath='{.data.ENVIRONMENT}'
# Output: development

# Staging
kubectl get configmap app-config -n staging -o jsonpath='{.data.ENVIRONMENT}'
# Output: staging

# Production
kubectl get configmap app-config -n prod -o jsonpath='{.data.ENVIRONMENT}'
# Output: production
```

### Check Secret Keys Without Values

```bash
# List secret keys without exposing values
kubectl get secret app-secrets -n prod -o jsonpath='{.data}' | jq 'keys'

# Output example:
# [
#   "api-key",
#   "db-connection-string",
#   "db-password",
#   "jwt-secret",
#   "tls-cert",
#   "tls-key"
# ]
```

### Rotate a Secret

```bash
# Rotate database password in production
./scripts/rotate-secrets.sh prod db-password

# The script will:
# 1. Generate new password
# 2. Update Kubernetes secret
# 3. Trigger pod restart
# 4. Verify new pods are running
```

### Update ConfigMap

```bash
# Edit ConfigMap in-cluster
kubectl edit configmap app-config -n dev

# Or update via patch
kubectl patch configmap app-config -n dev -p '{"data":{"LOG_LEVEL":"INFO"}}'

# Restart pods to pick up new config
kubectl rollout restart deployment/config-demo -n dev
```

### View Pod Logs

```bash
# View logs from all pods in an environment
kubectl logs -n dev -l app=config-demo --tail=50 -f

# View logs from specific pod
POD=$(kubectl get pods -n dev -l app=config-demo -o jsonpath='{.items[0].metadata.name}')
kubectl logs $POD -n dev --tail=100
```

## Best Practices

### ConfigMap Management
✅ **DO:**
- Store non-sensitive configuration data
- Use clear, descriptive key names
- Version your configs alongside code
- Document all available configuration options

❌ **DON'T:**
- Store secrets in ConfigMaps
- Use ConfigMaps for large files (>1MB)
- Hardcode environment-specific values in base configs

### Secret Management
✅ **DO:**
- Use Kubernetes Secrets for all sensitive data
- Enable encryption at rest in Kubernetes
- Use strong, randomly generated passwords
- Audit secret access and changes
- Rotate secrets regularly
- Use separate secrets per environment
- Store secret credentials in secure vaults (HashiCorp Vault, AWS Secrets Manager)

❌ **DON'T:**
- Commit secrets to Git repositories
- Use weak or default passwords
- Share secrets via unencrypted channels
- Store secrets in ConfigMaps
- Use base64 as encryption (it's encoding, not encryption!)

### RBAC Best Practices
✅ **DO:**
- Create separate service accounts per application
- Grant minimal necessary permissions (principle of least privilege)
- Use Role and RoleBinding for namespace-scoped access
- Audit RBAC policy changes

❌ **DON'T:**
- Use cluster-admin role for applications
- Grant wildcard (*) permissions
- Reuse service accounts across applications

### Environment Separation
✅ **DO:**
- Use separate namespaces for each environment
- Use Kustomize overlays for environment-specific configs
- Implement network policies to restrict traffic
- Use resource quotas per namespace

❌ **DON'T:**
- Mix environments in the same namespace
- Hard-code environment values in base configs
- Share secrets between environments

### Secret Rotation
✅ **DO:**
- Rotate secrets on a regular schedule
- Update both old and new versions temporarily
- Trigger pod restarts after secret rotation
- Keep audit logs of all rotations

❌ **DON'T:**
- Delete secrets without backup
- Rotate secrets during critical periods without testing
- Forget to update dependent systems

## Troubleshooting

### Issue: Pods Won't Start

```bash
# Check pod status
kubectl describe pod <pod-name> -n dev

# View pod logs for errors
kubectl logs <pod-name> -n dev

# Common causes:
# - ConfigMap or Secret not found
# - Image pull errors
# - Resource limits exceeded
```

### Issue: ConfigMap Not Mounted

```bash
# Verify ConfigMap exists
kubectl get configmap app-config -n dev

# Check if ConfigMap is referenced in deployment
kubectl get deployment config-demo -n dev -o yaml | grep -A5 envFrom

# Delete and recreate if corrupted
kubectl delete configmap app-config -n dev
kubectl apply -k overlays/dev
```

### Issue: Secrets Not Accessible

```bash
# Verify Secret exists
kubectl get secret app-secrets -n prod

# Check Service Account permissions
kubectl get rolebindings -n prod

# Verify RBAC policy
kubectl get role config-demo-reader -n prod -o yaml

# Check pod running as correct service account
kubectl get pod <pod-name> -n prod -o jsonpath='{.spec.serviceAccountName}'
```

### Issue: Environment Variables Not Set

```bash
# Verify variables are set in pod
kubectl exec <pod-name> -n dev -- env | grep APP_

# Check if ConfigMap/Secret keys match expected variable names
kubectl get configmap app-config -n dev -o jsonpath='{.data}' | jq keys
kubectl get secret app-secrets -n dev -o jsonpath='{.data}' | jq keys

# Verify deployment references ConfigMap/Secret
kubectl get deployment config-demo -n dev -o yaml | grep -A10 envFrom
```

### Debug Commands Reference

```bash
# Get all resources in an environment
kubectl get all -n dev

# Describe deployment
kubectl describe deployment config-demo -n dev

# Check events
kubectl get events -n dev --sort-by='.lastTimestamp'

# Execute command in pod
kubectl exec -it <pod-name> -n dev -- /bin/bash

# Port forward for testing
kubectl port-forward svc/config-demo 8080:5000 -n dev

# View resource usage
kubectl top pods -n dev

# Get deployment status
kubectl rollout status deployment/config-demo -n dev

# View rollout history
kubectl rollout history deployment/config-demo -n dev
```

## Advanced Topics

### External Secrets Operator (ESO)
For production, consider using External Secrets Operator to sync secrets from external providers:
```bash
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets \
  external-secrets/external-secrets \
  -n external-secrets-system \
  --create-namespace
```

### Sealed Secrets for GitOps
Encrypt secrets for storage in Git:
```bash
# Install sealed-secrets controller
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.18.0/controller.yaml
```

### Vault Integration
Use HashiCorp Vault for centralized secret management with dynamic credentials and audit trails.

### ArgoCD Integration
For GitOps-based deployments:
```bash
# Sync configuration from Git
argocd app sync config-demo-dev
```

---

**Last Updated**: 2026-09-19  
**Version**: 1.0.0  
**Author**: DevOps Learning Project
