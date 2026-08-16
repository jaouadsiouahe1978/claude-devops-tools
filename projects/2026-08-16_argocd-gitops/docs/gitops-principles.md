# GitOps Principles & Concepts

## What is GitOps?

**GitOps** is an operational framework that takes DevOps best practices used for application development (like version control, code review, CI/CD) and applies them to infrastructure automation and deployment.

### Core Concept
> **Git is the single source of truth** for the desired state of your systems.

---

## Four Core Principles of GitOps

### 1. **Declarative Description**
- Systems are fully described declaratively (YAML, HCL, etc.)
- Not imperative (no scripts that make changes step-by-step)
- Example:
  ```yaml
  # Declarative (GitOps way) ✅
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: my-app
  spec:
    replicas: 3
  ```
  ```bash
  # Imperative (old way) ❌
  kubectl scale deployment my-app --replicas=3
  ```

### 2. **Versioned & Immutable**
- All configuration stored in Git (version control)
- Complete audit trail of all changes
- Easy rollback to any previous state
- Easy recovery from disasters

### 3. **Pulled Automatically**
- Operators pull desired state from Git
- No push model (external script pushing changes)
- Agent in cluster continuously checks Git
- **Pull-based > Push-based** for security

### 4. **Continuously Reconciled**
- System continuously syncs with Git state
- Automatic detection of drift
- Auto-remediation if anything changes
- Self-healing capabilities

---

## Push vs Pull Models

### Traditional Push Model (CI/CD)
```
Developer → Git → CI Pipeline → kubectl apply (push to cluster)
```

**Problems:**
- Requires cluster credentials in CI pipeline (security risk)
- Pipeline must have network access to cluster
- Difficult to implement in multi-cluster scenarios
- Hard to audit actual cluster state

### GitOps Pull Model (Recommended)
```
Developer → Git (desired state)
           ↓
        ArgoCD (agent in cluster)
           ↓
        Kubernetes Cluster (pulls and applies)
```

**Advantages:**
- Cluster credentials never leave cluster
- Better security posture
- Works across firewalls/private networks
- Easy to implement disaster recovery
- Natural multi-cluster support

---

## Architecture Patterns

### Pattern 1: Single Repo, Multiple Apps
```
my-gitops-repo/
├── apps/
│   ├── frontend/
│   │   └── kustomization.yaml
│   └── backend/
│       └── kustomization.yaml
└── charts/
    └── shared-services/
```

**Pros:** Centralized, simple to manage
**Cons:** Single point of failure, scaling challenges

### Pattern 2: Mono Repo with Environments
```
my-gitops-repo/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
└── base/
    ├── app1/
    └── app2/
```

**Pros:** Environment parity, easy promotion
**Cons:** Larger repo, can become unwieldy

### Pattern 3: Multiple Repos (Polyrepo)
```
my-gitops-repo/ (infra, config)
├── environments/
└── operators/

app1-repo/ (app source code)
├── .github/
├── charts/
└── src/

app2-repo/ (app source code)
└── ...
```

**Pros:** Team ownership, flexible scaling
**Cons:** Complex synchronization, multiple sources of truth

---

## Synchronization Strategies

### 1. **Sync Status: Synced**
- Cluster state matches Git declaration exactly
- All resources healthy and running
- **Desired state achieved** ✅

### 2. **Sync Status: OutOfSync**
- Cluster state differs from Git
- Could be due to:
  - Manual changes via `kubectl` (anti-pattern)
  - Cluster autoscaling changes
  - External system changes
- **Needs reconciliation**

### 3. **Health Status: Healthy**
- All resources are operational
- Deployments at target replicas
- Services have endpoints

### 4. **Health Status: Progressing**
- Changes being applied
- Waiting for deployments to scale up
- **Normal during updates**

### 5. **Health Status: Degraded**
- Resources in error state
- Pods stuck in pending/error
- **Requires investigation**

---

## Implementation Workflow

### Developer Workflow
```
1. Make code changes
   ↓
2. Update manifests in Git repo
   ↓
3. Create Pull Request
   ↓
4. Code review & approval
   ↓
5. Merge to main branch
   ↓
6. ArgoCD detects change
   ↓
7. ArgoCD syncs to cluster
   ↓
8. Application updated automatically
```

### Git Commit → Deployment Flow
```
Developer commits manifest change
    ↓
Git webhook notifies ArgoCD (or polling every 3 min)
    ↓
ArgoCD compares Git with cluster state
    ↓
ArgoCD generates deployment plan
    ↓
ArgoCD applies manifests to cluster
    ↓
Kubernetes reconciles state
    ↓
Application is live
```

---

## Secrets Management in GitOps

### Problem
Git should contain everything, but secrets can't be in plain text in Git!

### Solutions

#### 1. External Secret Operators
```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secrets
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
      auth:
        jwt: {}
```

#### 2. Sealed Secrets
```bash
echo -n "mysecret" | kubectl create secret generic mysecret \
  --dry-run=client --from-file=/dev/stdin | \
  kubeseal -f - > mysealedsecret.yaml
```

#### 3. SOPS (Secrets Operations)
```bash
sops --encrypt secrets.yaml > secrets.encrypted.yaml
# Decrypt in GitOps operator pipeline
```

#### 4. HashiCorp Vault
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vault-auth
# Cluster uses Vault for secret injection
```

---

## Progressive Delivery Patterns

### Blue-Green Deployment
```
Blue (v1) [Live Traffic]
Green (v2) [Staging]
    ↓
Test Green
    ↓
Switch Traffic to Green
    ↓
Blue becomes new Staging
```

**In Git:**
```yaml
# Change service selector
selector:
  version: green  # from "blue"
```

### Canary Deployment
```
v1: 90% of traffic
v2:  10% of traffic
    ↓
Monitor metrics
    ↓
Gradually shift traffic: 90%→0%, 10%→100%
```

**Tools:** Flagger + ArgoCD for automated canary

### Rolling Update
```
Old: ████░░░░░  (80% done)
New: ░░░░████  (20% done)
```

**In Kubernetes:**
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0
```

---

## Disaster Recovery (DR) with GitOps

### Recovery from Disaster
```
Cluster Failure / Data Loss
    ↓
Recreate cluster infrastructure
    ↓
Deploy ArgoCD
    ↓
Point to same Git repository
    ↓
ArgoCD syncs everything automatically
    ↓
✅ Full system recovered
```

**Time to recovery:** Minutes instead of hours

### The Git Repo is Your Backup
```
Every commit = complete system snapshot
Every branch = alternate reality
Easy rollback to any point in time
```

---

## Best Practices

### 1. **Repository Structure**
```
gitops-repo/
├── README.md
├── .gitignore
├── base/                    # Base configurations
│   ├── app1/
│   └── app2/
├── overlays/               # Environment-specific
│   ├── dev/
│   ├── staging/
│   └── prod/
├── operators/              # Operators and CRDs
└── docs/                   # Documentation
```

### 2. **Commit Messages**
```bash
✅ Good:
git commit -m "feat: scale frontend to 5 replicas in prod"
git commit -m "fix: update nginx image to 1.24-alpine"
git commit -m "chore: add resource requests for backend"

❌ Bad:
git commit -m "fix"
git commit -m "update"
```

### 3. **Pull Request Process**
```
1. Feature branch with manifest changes
2. Test with `kustomize build`
3. Code review (should include ops review)
4. Approval before merge
5. Merge to main = deployment to cluster
```

### 4. **Secrets Handling**
- ❌ Never commit plain-text secrets
- ✅ Use sealed-secrets or external-secrets
- ✅ Rotate secrets regularly
- ✅ Audit secret access

### 5. **Testing**
```bash
# Validate YAML
kustomize build | kubeval

# Dry-run
kustomize build | kubectl apply --dry-run=client -f -

# Check diffs
argocd app diff my-app

# Policy enforcement (OPA/Kyverno)
```

### 6. **Monitoring & Alerting**
- Alert on sync failures
- Alert on health degradation
- Monitor Git webhook latency
- Track deployment frequency metrics

---

## Common Pitfalls

### 1. **Manual Kubectl Changes**
```bash
# ❌ This breaks GitOps!
kubectl set image deployment/app app=image:v2

# ✅ Do this instead:
# Update manifests in Git
git commit -m "Update app image to v2"
git push
# ArgoCD syncs automatically
```

### 2. **Incomplete Declarative State**
```bash
# ❌ Some resources in Git, others created manually
# ✅ Everything in Git, nothing manual

# ✅ Audit:
argocd app resources my-app  # Should list all resources
```

### 3. **Large Monolithic Repos**
```bash
# ❌ Everything in one repo, hard to scale
# ✅ Separate repos by team/component
```

### 4. **Poor Secrets Management**
```bash
# ❌ Secrets in Git (even in private repos!)
# ✅ Use sealed-secrets, external-secrets, or Vault
```

### 5. **No Disaster Recovery Testing**
```bash
# ❌ Assume it will work when needed
# ✅ Test cluster recovery regularly
#    1. Delete cluster
#    2. Recreate from Git
#    3. Verify everything works
```

---

## Tools in the GitOps Ecosystem

| Tool | Purpose |
|------|---------|
| **ArgoCD** | GitOps operator, declarative deployment |
| **Flux** | Alternative to ArgoCD, cloud-native |
| **Kustomize** | Template-free customization |
| **Helm** | Package manager for Kubernetes |
| **Sealed Secrets** | Encrypt secrets in Git |
| **External Secrets** | Sync secrets from external providers |
| **Kyverno** | Policy enforcement |
| **OPA/Gatekeeper** | Policy as code |
| **Prometheus + Grafana** | Monitoring |

---

## Summary

**GitOps = Infrastructure as Code + Git + Automation**

- ✅ Single source of truth (Git)
- ✅ Version controlled everything
- ✅ Audit trail of all changes
- ✅ Automated deployments
- ✅ Self-healing systems
- ✅ Easy disaster recovery
- ✅ Security through pull model
- ✅ Team collaboration

**Key Takeaway:** Push your changes to Git, and let ArgoCD handle the deployment! 🚀
