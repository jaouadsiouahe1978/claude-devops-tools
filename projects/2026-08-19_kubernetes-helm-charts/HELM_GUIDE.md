# Helm Chart Guide - Complete Learning Path

## Table of Contents
1. [Helm Basics](#helm-basics)
2. [Chart Structure](#chart-structure)
3. [Templates and Variables](#templates-and-variables)
4. [Values and Environments](#values-and-environments)
5. [Advanced Concepts](#advanced-concepts)
6. [Troubleshooting](#troubleshooting)

---

## Helm Basics

### What is Helm?

Helm is a **package manager for Kubernetes** that allows you to:
- Package your Kubernetes manifests into reusable charts
- Template manifests with variables for different environments
- Manage releases with version control and rollbacks
- Share charts publicly via repositories

### Why Use Helm?

Instead of managing multiple YAML files:
```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
```

You can do:
```bash
helm install myapp ./charts/myapp-chart
```

### Install Helm

```bash
# On macOS
brew install helm

# On Linux
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installation
helm version
```

---

## Chart Structure

### Default Chart Layout

```
charts/myapp-chart/
├── Chart.yaml                 # Chart metadata (name, version, description)
├── values.yaml                # Default configuration values
├── values-dev.yaml            # Development environment values
├── values-prod.yaml           # Production environment values
├── charts/                     # Dependency charts (optional)
├── templates/                  # Kubernetes manifest templates
│   ├── _helpers.tpl           # Helper functions
│   ├── deployment.yaml        # Deployment template
│   ├── service.yaml           # Service template
│   ├── configmap.yaml         # ConfigMap template
│   ├── secret.yaml            # Secret template
│   ├── ingress.yaml           # Ingress template
│   ├── pvc.yaml               # PersistentVolumeClaim template
│   └── hpa.yaml               # HorizontalPodAutoscaler template
└── README.md                   # Chart documentation
```

### Chart.yaml Explained

```yaml
apiVersion: v2                  # Helm API version (v2 for Helm 3)
name: myapp                     # Chart name
description: My Application     # Chart description
type: application               # Type: application or library
version: 1.0.0                  # Chart version (semantic versioning)
appVersion: "1.0"               # Application version inside the chart
keywords:                       # Keywords for searching
  - myapp
  - kubernetes
maintainers:                    # Chart maintainers
  - name: Your Name
    email: your@email.com
home: https://github.com/...    # Project homepage
sources:                        # Source code locations
  - https://github.com/...
icon: https://...               # Chart icon URL
```

---

## Templates and Variables

### Helm Templating Syntax

Helm uses Go templating with two types of delimiters:

#### 1. Action Delimiters `{{ }}`

```yaml
# Simple variable substitution
image: "{{ .Values.backend.image.repository }}:{{ .Values.backend.image.tag }}"

# Result: image: "python:3.11-slim"
```

#### 2. Control Structures

**Conditionals:**
```yaml
{{- if .Values.frontend.enabled }}
kind: Deployment
metadata:
  name: {{ include "myapp.fullname" . }}-frontend
  # ... rest of manifest
{{- end }}
```

**Loops:**
```yaml
env:
{{- range .Values.backend.env }}
- name: {{ .name }}
  value: "{{ .value }}"
{{- end }}
```

**Default Values:**
```yaml
replicas: {{ .Values.replicas | default 2 }}
```

#### 3. Built-in Variables

```yaml
# Release information
{{ .Release.Name }}      # Release name (e.g., "myapp")
{{ .Release.Namespace }} # Namespace
{{ .Release.Service }}   # "Helm" (always)

# Chart information
{{ .Chart.Name }}        # Chart name
{{ .Chart.Version }}     # Chart version
{{ .Chart.AppVersion }}  # Application version

# Template context
{{ .Values.key }}        # Access values.yaml
{{ . }}                  # Current object
```

### Helper Functions (from _helpers.tpl)

```yaml
# In templates, use helper functions for DRY code
metadata:
  name: {{ include "myapp.fullname" . }}
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
  selector:
    matchLabels:
      {{- include "myapp.selectorLabels" . | nindent 6 }}
```

Helper functions are defined in `_helpers.tpl`:
```yaml
{{- define "myapp.fullname" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}
```

---

## Values and Environments

### values.yaml (Default Configuration)

This is the default configuration that Helm uses:

```yaml
# Global configuration
replicaCount: 2
environment: development

# Component-specific settings
frontend:
  enabled: true
  image:
    repository: nginx
    tag: "1.24-alpine"
  replicas: 2
  resources:
    limits:
      cpu: 200m
      memory: 256Mi

backend:
  enabled: true
  replicas: 2
  resources:
    limits:
      cpu: 500m
      memory: 512Mi

database:
  enabled: true
  persistence:
    size: 10Gi
```

### Environment-Specific Values

**values-dev.yaml (Development Override):**
```yaml
# Override only what's different from values.yaml
replicaCount: 1

frontend:
  replicas: 1
  resources:
    limits:
      cpu: 100m
      memory: 128Mi

database:
  persistence:
    enabled: false  # Don't persist in dev
```

**values-prod.yaml (Production Override):**
```yaml
# Override for production
replicaCount: 3

frontend:
  replicas: 3
  autoscaling:
    enabled: true
    maxReplicas: 10

database:
  persistence:
    size: 100Gi
    storageClassName: "fast-ssd"
```

### Using Different Values Files

```bash
# Use default values.yaml
helm install myapp ./charts/myapp-chart

# Use development values
helm install myapp ./charts/myapp-chart -f values-dev.yaml

# Use production values
helm install myapp ./charts/myapp-chart -f values-prod.yaml

# Override specific values on command line
helm install myapp ./charts/myapp-chart \
  --set backend.replicas=5 \
  --set database.persistence.size=50Gi

# Combine multiple value files and overrides
helm install myapp ./charts/myapp-chart \
  -f values-prod.yaml \
  -f values-prod-overrides.yaml \
  --set image.tag=v2.0.0
```

---

## Advanced Concepts

### 1. Conditional Deployment

Deploy components only when enabled:

```yaml
{{- if .Values.frontend.enabled }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "myapp.fullname" . }}-frontend
spec:
  replicas: {{ .Values.frontend.replicas }}
  # ... rest of manifest
{{- end }}

{{- if .Values.backend.enabled }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "myapp.fullname" . }}-backend
spec:
  replicas: {{ .Values.backend.replicas }}
  # ... rest of manifest
{{- end }}
```

This allows using the same chart for different application combinations.

### 2. Auto-scaling with HPA

```yaml
{{- if .Values.backend.autoscaling.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "myapp.fullname" . }}-backend
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "myapp.fullname" . }}-backend
  minReplicas: {{ .Values.backend.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.backend.autoscaling.maxReplicas }}
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: {{ .Values.backend.autoscaling.targetCPUUtilizationPercentage }}
{{- end }}
```

### 3. Secrets Management

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "myapp.fullname" . }}-db-secret
type: Opaque
data:
  # Values are base64 encoded by Helm
  POSTGRES_PASSWORD: {{ .Values.database.config.POSTGRES_PASSWORD | b64enc | quote }}
  API_KEY: {{ .Values.secrets.apiKey | b64enc | quote }}
```

**Best Practice:** Don't commit actual secrets to Git! Use:
```bash
# Use --set for secrets
helm install myapp ./charts/myapp-chart \
  --set database.config.POSTGRES_PASSWORD=$(cat /secure/password.txt)

# Or use external secrets management
# - External Secrets Operator
# - Sealed Secrets
# - HashiCorp Vault
```

### 4. ConfigMap Templates

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "myapp.fullname" . }}-config
data:
  # Simple values
  LOG_LEVEL: "{{ .Values.config.LOG_LEVEL }}"
  ENVIRONMENT: "{{ .Values.environment }}"

  # Multiline content
  nginx.conf: |
    server {
      listen 80;
      location / {
        proxy_pass http://backend:8080;
      }
    }

  # From nested values
  max_connections: "{{ .Values.config.MAX_CONNECTIONS }}"
```

### 5. Ingress Configuration

```yaml
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "myapp.fullname" . }}
  annotations:
    {{- toYaml .Values.ingress.annotations | nindent 4 }}
spec:
  ingressClassName: {{ .Values.ingress.className }}
  tls:
    - hosts:
        {{- range .Values.ingress.hosts }}
        - {{ .host }}
        {{- end }}
      secretName: {{ include "myapp.fullname" . }}-tls
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType }}
            backend:
              service:
                name: {{ include "myapp.fullname" . }}-frontend
                port:
                  number: 80
          {{- end }}
    {{- end }}
{{- end }}
```

### 6. Persistent Storage

```yaml
{{- if and .Values.database.enabled .Values.database.persistence.enabled }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "myapp.fullname" . }}-db-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: {{ .Values.database.persistence.size }}
  storageClassName: {{ .Values.database.persistence.storageClassName }}
{{- end }}
```

---

## Helm Commands

### Chart Management

```bash
# Create a new chart from scratch
helm create myapp

# Lint a chart for errors
helm lint ./charts/myapp-chart

# Validate chart syntax (strict)
helm lint ./charts/myapp-chart --strict

# Check chart dependencies
helm dependency list ./charts/myapp-chart
helm dependency update ./charts/myapp-chart

# Package a chart for distribution
helm package ./charts/myapp-chart
# Creates: myapp-1.0.0.tgz
```

### Template Debugging

```bash
# See generated Kubernetes manifests without installing
helm template myapp ./charts/myapp-chart

# With specific values
helm template myapp ./charts/myapp-chart -f values-prod.yaml

# See rendered manifests for specific resource type
helm template myapp ./charts/myapp-chart | grep -A 20 "kind: Deployment"

# Simulate installation without actually installing (dry-run)
helm install myapp ./charts/myapp-chart --dry-run --debug

# Save manifests to file for inspection
helm template myapp ./charts/myapp-chart > /tmp/manifests.yaml
kubectl apply -f /tmp/manifests.yaml --dry-run=client
```

### Release Management

```bash
# Install a release
helm install myapp ./charts/myapp-chart -n default

# Install with custom values
helm install myapp ./charts/myapp-chart -f values-prod.yaml

# Install to specific namespace (create if doesn't exist)
helm install myapp ./charts/myapp-chart \
  -n production \
  --create-namespace

# Install with custom release name
helm install my-custom-release ./charts/myapp-chart

# Check release status
helm status myapp

# Get values for a release
helm get values myapp

# Get manifests for a release
helm get manifest myapp

# List all releases
helm list
helm list --all-namespaces
```

### Upgrades and Rollbacks

```bash
# Upgrade to new chart version or values
helm upgrade myapp ./charts/myapp-chart -f values-prod.yaml

# Upgrade with auto-rollback on failure
helm upgrade myapp ./charts/myapp-chart --atomic

# Preview upgrade changes
helm upgrade myapp ./charts/myapp-chart --dry-run

# View release history
helm history myapp

# Rollback to previous release
helm rollback myapp

# Rollback to specific revision
helm rollback myapp 2

# Uninstall a release
helm uninstall myapp

# Uninstall and keep history
helm uninstall myapp --keep-history
```

### Repository Operations

```bash
# Add a chart repository
helm repo add stable https://charts.helm.sh/stable

# Update repository indexes
helm repo update

# Search for charts
helm search repo nginx
helm search repo --all

# Install from repository
helm install my-nginx stable/nginx-ingress

# List repositories
helm repo list

# Remove a repository
helm repo remove stable
```

---

## Troubleshooting

### Common Issues and Solutions

#### 1. Manifest Rendering Issues

```bash
# Error: variables not found
# Solution: Check template syntax and variable names

# Debug: Print rendered manifests
helm template myapp ./charts/myapp-chart

# Debug: Check values structure
helm get values myapp
```

#### 2. Resource Not Creating

```bash
# Check if all dependencies are met
kubectl get nodes
kubectl get storageclass

# Check events
kubectl describe pod myapp-frontend-xyz
kubectl get events -n default

# Check resource quotas
kubectl describe resourcequota -n default
```

#### 3. Pods Not Starting

```bash
# View pod logs
kubectl logs -n default deployment/myapp-frontend

# Follow logs in real-time
kubectl logs -n default deployment/myapp-backend -f

# View previous logs if pod crashed
kubectl logs -n default deployment/myapp-db --previous

# Describe pod for events
kubectl describe pod myapp-frontend-xyz
```

#### 4. Upgrade Failed

```bash
# Check release status
helm status myapp

# View history of failed releases
helm history myapp

# Rollback to last working version
helm rollback myapp

# Check what went wrong
helm get manifest myapp | kubectl diff -f -
```

#### 5. ConfigMap/Secret Not Updating

```bash
# After updating ConfigMap, restart pods to pick up changes
kubectl rollout restart deployment/myapp-backend

# Verify ConfigMap was updated
kubectl get configmap myapp-config -o yaml

# View ConfigMap contents
kubectl describe configmap myapp-config
```

---

## Helm Best Practices

### 1. Semantic Versioning
```yaml
# Chart version should follow semantic versioning
version: 1.0.0    # MAJOR.MINOR.PATCH
# Increment:
# - MAJOR: Breaking changes
# - MINOR: Backward-compatible features
# - PATCH: Bug fixes
```

### 2. Meaningful Labels and Annotations
```yaml
metadata:
  labels:
    app: myapp
    version: "1.0"
    environment: production
  annotations:
    description: "Production API server"
    managed-by: "helm"
```

### 3. Resource Limits
```yaml
resources:
  requests:
    cpu: 250m        # Minimum guaranteed resources
    memory: 256Mi
  limits:
    cpu: 500m        # Maximum allowed resources
    memory: 512Mi
```

### 4. Readiness and Liveness Probes
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

### 5. Security Context
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
```

### 6. Anti-Affinity for High Availability
```yaml
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
              - key: app
                operator: In
                values:
                  - myapp
          topologyKey: kubernetes.io/hostname
```

---

## Useful Resources

- [Helm Official Documentation](https://helm.sh/docs/)
- [Helm Chart Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Artifact Hub - Public Charts](https://artifacthub.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Template Functions](https://helm.sh/docs/chart_template_guide/function_list/)

---

**Happy Helming! 🚀**
