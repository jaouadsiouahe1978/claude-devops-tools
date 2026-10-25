# Helm Charts - Usage Examples

## Example 1: Development Deployment

For a quick development environment with minimal resources:

```bash
# Validate the chart
cd myapp
helm lint .

# Deploy to dev namespace
helm install myapp-dev . -f values-dev.yaml -n dev --create-namespace

# Check deployment status
kubectl get pods -n dev
kubectl get svc -n dev

# Port forward to access frontend
kubectl port-forward -n dev svc/myapp-dev-frontend 8080:80

# View API logs
kubectl logs -n dev deployment/myapp-dev-api -f

# View database status
kubectl exec -it -n dev $(kubectl get pod -n dev -l component=postgres -o jsonpath='{.items[0].metadata.name}') -- psql -U appuser -d appdb
```

## Example 2: Production Deployment

For a highly available production setup:

```bash
# Validate with prod values
helm lint .

# Create production namespace
kubectl create namespace production

# Deploy to production with enhanced resources
helm install myapp-prod . \
  -f values-prod.yaml \
  -n production \
  --set postgres.env.POSTGRES_PASSWORD=$(openssl rand -base64 32) \
  --set ingress.hosts[0].host=myapp.example.com

# Verify all replicas are running
kubectl get deploy -n production
kubectl get pods -n production

# Check ingress
kubectl get ingress -n production
```

## Example 3: Multi-Environment Setup

Deploy the same app to multiple environments:

```bash
# Dev
helm install myapp-dev . -f values-dev.yaml -n dev --create-namespace

# Staging
helm install myapp-staging . -f values.yaml -n staging --create-namespace \
  --set global.environment=staging \
  --set global.domain=staging.myapp.com

# Production
helm install myapp-prod . -f values-prod.yaml -n production --create-namespace \
  --set global.domain=myapp.example.com
```

## Example 4: Update Application Version

Rolling update to a new API version:

```bash
# Update API image version
helm upgrade myapp-prod . \
  -f values-prod.yaml \
  --set api.image.tag=2.0.0 \
  --atomic

# Watch the rollout
kubectl rollout status deployment/myapp-prod-api -n production

# Verify new version
kubectl get pods -n production -o wide
```

## Example 5: Scale Horizontal

Increase replicas for high traffic:

```bash
# Double the replicas
helm upgrade myapp-prod . \
  -f values-prod.yaml \
  --set frontend.replicaCount=6 \
  --set api.replicaCount=6

# Monitor rollout
kubectl get pods -n production -w
```

## Example 6: Modify Configuration

Update environment variables:

```bash
# Change log level
helm upgrade myapp-prod . \
  -f values-prod.yaml \
  --set api.env.LOG_LEVEL=DEBUG

# Verify ConfigMap change
kubectl get cm myapp-prod-config -o yaml
```

## Example 7: Troubleshooting

Common troubleshooting commands:

```bash
# Check helm release status
helm status myapp-prod -n production

# Get all resources created by helm
helm get manifest myapp-prod -n production

# Compare template rendering
helm template myapp-prod . -f values-prod.yaml > prod-manifest.yaml
kubectl diff -f prod-manifest.yaml -n production

# View helm history
helm history myapp-prod -n production

# Debug template rendering issues
helm template myapp-prod . --debug
```

## Example 8: Rollback

Rollback to previous version if something goes wrong:

```bash
# Check previous releases
helm history myapp-prod -n production

# Rollback to previous
helm rollback myapp-prod 1 -n production

# Verify rollback
helm status myapp-prod -n production
kubectl get pods -n production
```

## Example 9: Custom Values Overlay

Merge multiple values files:

```bash
# Apply base + environment + custom overrides
helm install myapp . \
  -f values.yaml \
  -f values-prod.yaml \
  -f custom-overrides.yaml \
  -n production
```

## Example 10: Dry Run Before Deploy

Always test first:

```bash
# Dry run to see what would be created
helm install myapp-test . -f values-prod.yaml --dry-run --debug

# Generate manifest without deploying
helm template myapp . -f values-prod.yaml > myapp-manifest.yaml

# Apply manifest manually for testing
kubectl apply -f myapp-manifest.yaml --dry-run=client
```

## Helm Values Override Examples

```bash
# Override single value
helm install myapp . --set api.replicaCount=5

# Override nested value
helm install myapp . --set postgres.resources.limits.memory=2Gi

# Override list values
helm install myapp . --set 'ingress.hosts[0].host=myapp.com'

# String values with special characters
helm install myapp . --set 'postgres.env.POSTGRES_PASSWORD=P@ssw0rd!123'

# Boolean values
helm install myapp . --set 'ingress.enabled=false'

# Multiple overrides
helm install myapp . \
  --set api.replicaCount=3 \
  --set frontend.replicaCount=2 \
  --set global.environment=production
```
