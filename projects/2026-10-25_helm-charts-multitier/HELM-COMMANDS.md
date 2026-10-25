# Helm Commands - Multi-tier Application

## Chart Validation

```bash
# Lint the chart for errors
helm lint myapp/

# Validate chart structure
helm template myapp/

# See what would be deployed (dry-run)
helm template myapp/ -f myapp/values.yaml
helm template myapp/ -f myapp/values-dev.yaml
helm template myapp/ -f myapp/values-prod.yaml
```

## Installation

```bash
# Install with default values (dev)
helm install myapp myapp/

# Install with dev values
helm install myapp-dev myapp/ -f myapp/values-dev.yaml

# Install with prod values
helm install myapp-prod myapp/ -f myapp/values-prod.yaml

# Install in specific namespace
helm install myapp myapp/ -n production --create-namespace

# Install with custom image tags
helm install myapp myapp/ --set api.image.tag=2.0.0 --set frontend.image.tag=1.5.0
```

## Upgrade

```bash
# Upgrade release with new values
helm upgrade myapp myapp/ -f myapp/values-prod.yaml

# Upgrade and rollback on failure
helm upgrade myapp myapp/ --atomic

# Upgrade with new images
helm upgrade myapp myapp/ \
  --set api.image.tag=2.1.0 \
  --set postgres.image.tag=16-alpine
```

## Debugging

```bash
# List installed releases
helm list
helm list -n production

# Get values of installed release
helm get values myapp

# Get manifest of installed release
helm get manifest myapp

# Show release history
helm history myapp

# Get detailed release info
helm status myapp
```

## Rollback

```bash
# Rollback to previous version
helm rollback myapp 1

# Rollback to specific revision
helm rollback myapp 3
```

## Uninstall

```bash
# Uninstall release
helm uninstall myapp

# Uninstall with protection
helm uninstall myapp --keep-history

# Uninstall from specific namespace
helm uninstall myapp -n production
```

## Package and Release

```bash
# Package the chart
helm package myapp/

# Push to Helm repository (if configured)
helm repo add myrepo https://charts.example.com
helm push myapp-1.0.0.tgz myrepo
```

## Tips & Tricks

```bash
# Generate a random password for secrets
openssl rand -base64 32

# Override multiple values
helm install myapp myapp/ \
  -f values-prod.yaml \
  --set api.replicaCount=5 \
  --set postgres.resources.limits.memory=4Gi

# Use different values per component
helm install myapp myapp/ \
  --set frontend.enabled=false \
  --set ingress.enabled=false

# See template output for debugging
helm template myapp -f values-dev.yaml | grep -A 20 "kind: Deployment"

# Watch deployment rollout
kubectl rollout status deployment/myapp-frontend -n default
kubectl rollout history deployment/myapp-api
```

## Common Issues

### Issue: "Error: release name already exists"
```bash
helm uninstall myapp
# or use different release name
helm install myapp-v2 myapp/
```

### Issue: "ImagePullBackOff"
```bash
# Check if image exists
helm template myapp/ | grep image:
# Update values with correct image
helm upgrade myapp myapp/ --set api.image.repository=myregistry/api
```

### Issue: "CrashLoopBackOff"
```bash
# Check logs
kubectl logs deployment/myapp-api
kubectl logs deployment/myapp-frontend
# Check environment variables
kubectl get deployment myapp-api -o yaml | grep -A 10 "env:"
```
