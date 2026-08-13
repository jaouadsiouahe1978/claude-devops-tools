# Quick Start Guide - Helm Multi-Tier Deployment

## ⚡ 5 Minutes to First Deployment

### Option 1: Using Docker Compose (Fastest)

Perfect for learning Helm without needing a Kubernetes cluster:

```bash
# Start the application stack
docker-compose up -d

# Wait for services to be ready (30 seconds)
docker-compose ps

# Access the application
# Frontend: http://localhost:3000
# Backend API: http://localhost:5000
# Database: localhost:5432

# View logs
docker-compose logs -f

# Stop everything
docker-compose down -v
```

---

### Option 2: Using Helm on Kubernetes (Recommended)

#### Prerequisites
```bash
# Install Helm (if not already installed)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installation
helm version
kubectl cluster-info
```

#### Deploy to Development
```bash
# Make script executable
chmod +x deploy.sh

# Install the application
./deploy.sh install dev

# Verify deployment
./deploy.sh verify dev

# Get access information
./deploy.sh status dev
```

#### Access the Application
```bash
# Port forward frontend
kubectl port-forward -n dev svc/multitier-app-dev-frontend 3000:80

# In another terminal, access at http://localhost:3000
```

#### Common Commands
```bash
# See deployment status
kubectl get all -n dev

# View pod logs
kubectl logs -n dev -l app.kubernetes.io/component=frontend

# Execute commands in a pod
kubectl exec -it <pod-name> -n dev -- /bin/sh

# Upgrade the release
./deploy.sh upgrade dev

# Uninstall
./deploy.sh uninstall dev
```

---

## 🔧 Manual Helm Commands

If you prefer to run Helm commands directly:

### Development Deployment
```bash
# Create namespace
kubectl create namespace dev

# Deploy with Helm
helm install multitier-app-dev ./helm-chart \
  -f examples/values-dev.yaml \
  -n dev \
  --create-namespace

# Check status
helm list -n dev
helm status multitier-app-dev -n dev
```

### Production Deployment
```bash
# Edit the production values file first!
# Change passwords and API keys in examples/values-prod.yaml

# Deploy
helm install multitier-app-prod ./helm-chart \
  -f examples/values-prod.yaml \
  -n production \
  --create-namespace

# Verify
helm status multitier-app-prod -n production
```

### Upgrade a Release
```bash
# Make changes to values or chart
helm upgrade multitier-app-dev ./helm-chart \
  -f examples/values-dev.yaml \
  -n dev
```

### Rollback to Previous Version
```bash
# See revision history
helm history multitier-app-dev -n dev

# Rollback to previous revision
helm rollback multitier-app-dev 1 -n dev
```

### Uninstall
```bash
helm uninstall multitier-app-dev -n dev
```

---

## 📊 Verify Deployment

### Check All Resources
```bash
# List all pods, services, deployments
kubectl get all -n dev

# Describe a specific pod
kubectl describe pod <pod-name> -n dev
```

### Check Logs
```bash
# Frontend logs
kubectl logs -n dev -l app.kubernetes.io/component=frontend --tail=50

# Backend logs
kubectl logs -n dev -l app.kubernetes.io/component=backend --tail=50

# Database logs
kubectl logs -n dev -l app.kubernetes.io/component=database --tail=50

# Follow logs in real-time
kubectl logs -n dev -l app.kubernetes.io/component=frontend -f
```

### Test Connectivity
```bash
# Port forward to backend
kubectl port-forward -n dev svc/multitier-app-dev-backend 5000:5000

# In another terminal, test API
curl http://localhost:5000/health
curl http://localhost:5000/api/users
```

---

## 🔐 Security Considerations

### Before Production:

1. **Change Default Credentials**
   ```bash
   # Edit the production values file
   vi examples/values-prod.yaml
   
   # Change:
   # - database.auth.password
   # - secrets.apiKey
   # - secrets.jwtSecret
   ```

2. **Use Secret Management**
   ```bash
   # Install Sealed Secrets (or Vault)
   kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.18.0/controller.yaml -n kube-system
   ```

3. **Enable RBAC**
   - Already configured in the chart
   - Review ServiceAccount permissions

4. **Setup TLS/HTTPS**
   - Install cert-manager
   - Update ingress.tls in values

5. **Network Policies**
   - Uncomment networkPolicy in values.yaml
   - Restrict traffic between services

---

## 🐛 Troubleshooting

### Pods won't start
```bash
# Check pod status
kubectl describe pod <pod-name> -n dev

# Check resource limits
kubectl top nodes
kubectl top pods -n dev
```

### Services not communicating
```bash
# Test connectivity between pods
kubectl exec -it <pod-name> -n dev -- sh
# Inside the pod:
wget http://multitier-app-dev-backend:5000/health
```

### Database connection errors
```bash
# Check database pod logs
kubectl logs -n dev -l app.kubernetes.io/component=database

# Connect to database
kubectl run -it --rm debug --image=postgres:15-alpine --restart=Never -n dev -- \
  psql -h multitier-app-dev-postgresql -U postgres -d myapp
```

### Helm release issues
```bash
# Dry-run a deployment to see what would be created
helm install multitier-app-test ./helm-chart \
  -f examples/values-dev.yaml \
  -n test \
  --dry-run \
  --debug

# Template the chart to see rendered YAML
helm template multitier-app-test ./helm-chart \
  -f examples/values-dev.yaml
```

---

## 📚 Next Steps

1. **Customize for your app**
   - Replace placeholder images with your own
   - Update database schema in job-db-init.yaml
   - Modify frontend HTML/CSS

2. **Add more services**
   - Copy deployment-backend.yaml to create new services
   - Update values.yaml with new service configuration

3. **Implement CI/CD**
   - Create a .github/workflows/deploy.yml
   - Automate Helm releases on push

4. **Setup Monitoring**
   - Add Prometheus scrape configs
   - Create Grafana dashboards
   - Setup alerting

5. **Production Hardening**
   - Implement network policies
   - Setup pod security policies
   - Enable audit logging
   - Configure backup/restore

---

## 📖 Useful Resources

- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Chart Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Sprig Functions](http://masterminds.github.io/sprig/)

---

**Estimated Time**: 5-30 min depending on environment | **Difficulty**: Beginner
