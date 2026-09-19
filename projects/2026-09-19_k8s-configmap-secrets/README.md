# Kubernetes ConfigMap & Secret Management Across Environments

## 📋 Project Description
Master Kubernetes configuration management by implementing ConfigMaps and Secrets for different environments (dev, staging, prod). Learn how to manage environment-specific configurations, database credentials, and API keys securely across multiple deployments.

## 🎯 Learning Objectives
- Understand ConfigMaps for non-sensitive configuration data
- Implement Secrets for sensitive data (passwords, tokens, API keys)
- Manage environment-specific configurations using namespaces
- Use `kustomize` for environment-specific deployments
- Implement environment variables in containers
- Practice secure secret rotation patterns
- Learn RBAC for secret access control

## 🛠️ Technologies
- **Kubernetes 1.24+** - Container orchestration
- **kustomize** - Configuration management
- **kubectl** - Kubernetes CLI
- **base64** - Encoding secrets
- **YAML** - Configuration files

## 📋 Prerequisites
- Docker and Docker Desktop or Minikube/Kind cluster
- kubectl installed and configured
- Basic Kubernetes knowledge
- Access to a local K8s cluster

## 🚀 Implementation Steps

### 1. Initialize Project Structure
```
mkdir -p k8s-config-demo/{base,overlays/{dev,staging,prod}}
cd k8s-config-demo
```

### 2. Create Base Application
- Deploy a simple Python/Node.js app that reads configuration from environment variables
- The app will display: app name, environment, database config, API keys

### 3. Create ConfigMaps for Each Environment
- **Dev**: Quick iteration configuration (short timeouts, verbose logging)
- **Staging**: Production-like configuration (normal timeouts)
- **Prod**: Optimized configuration (encrypted, minimal logging)

### 4. Create Secrets for Sensitive Data
- Database passwords
- API keys
- JWT tokens
- TLS certificates

### 5. Use Kustomize for Environment Overlays
- Base deployment with common configuration
- Overlay for dev: insecure, verbose
- Overlay for staging: semi-secure, monitoring
- Overlay for prod: fully secure, minimal exposure

### 6. Deploy to All Environments
```bash
kubectl apply -k overlays/dev
kubectl apply -k overlays/staging
kubectl apply -k overlays/prod
```

### 7. Verify Configuration
- Check ConfigMaps: `kubectl get configmaps`
- Check Secrets: `kubectl get secrets`
- Verify pod environment variables
- Test application configuration loading

### 8. Secret Rotation Simulation
- Update a secret and trigger pod restart
- Demonstrate zero-downtime secret rotation

## 📊 What You'll Learn
✅ ConfigMap creation and management  
✅ Secret encoding and best practices  
✅ Environment-specific configurations  
✅ Kustomize overlays for DRY deployments  
✅ RBAC policies for secret access  
✅ Secret rotation and updates  
✅ Debugging configuration issues  
✅ Production-ready patterns  

## 📝 Files Included
- `base/deployment.yaml` - Common deployment definition
- `base/service.yaml` - Service definition
- `base/kustomization.yaml` - Base kustomization
- `overlays/dev/` - Development environment overlay with ConfigMaps & Secrets
- `overlays/staging/` - Staging environment overlay
- `overlays/prod/` - Production environment overlay
- `app/` - Simple Python Flask application
- `scripts/verify.sh` - Verification script

## 🎬 Quick Start
```bash
# Deploy development environment
kubectl apply -k overlays/dev

# Deploy staging environment
kubectl apply -k overlays/staging

# Deploy production environment
kubectl apply -k overlays/prod

# Verify all deployments
kubectl get all -n dev
kubectl get all -n staging
kubectl get all -n prod

# Check ConfigMaps
kubectl get configmaps -n dev

# Check Secrets
kubectl get secrets -n prod

# Port forward to test app
kubectl port-forward -n dev svc/config-demo 8080:5000

# View pod logs
kubectl logs -n dev -l app=config-demo
```

## 🔒 Security Best Practices Covered
- Never commit secrets to Git
- Use encrypted etcd in production
- Implement RBAC policies
- Rotate secrets regularly
- Use external secret management (HashiCorp Vault reference)
- Audit secret access
- Minimize secret scope

## 🔧 Troubleshooting
```bash
# Check if ConfigMap mounted correctly
kubectl exec -it <pod-name> -n dev -- env | grep APP_

# Debug secret mounting
kubectl describe pod <pod-name> -n prod

# View ConfigMap content
kubectl get configmap app-config -n dev -o yaml

# Recreate secrets
kubectl delete secret app-secrets -n prod
kubectl create secret generic app-secrets --from-literal=...
```

## 📚 Further Learning
- Kubernetes Secrets official docs
- Kustomize patches and overlays
- External Secrets Operator (ESO)
- HashiCorp Vault integration
- Sealed Secrets for GitOps
- RBAC for secret access control

## ✨ Deployment Summary
By completing this project, you'll have:
- A fully functional multi-environment Kubernetes application
- Environment-specific ConfigMaps and Secrets
- Kustomize overlays for DRY infrastructure
- A secure, scalable configuration management pattern
- Ready-to-use templates for your projects
