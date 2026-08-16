# ArgoCD CLI Reference Guide

## Installation

### Linux/macOS
```bash
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/
```

### Verify Installation
```bash
argocd version
```

---

## Authentication

### Login to ArgoCD Server
```bash
# Port-forward first
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Login
argocd login localhost:8080

# Or with explicit credentials
argocd login localhost:8080 --username admin --password <password>

# Or skip TLS verification (dev only!)
argocd login localhost:8080 --insecure
```

### Get Initial Password
```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

### Logout
```bash
argocd logout localhost:8080
```

---

## Repository Management

### Add Git Repository
```bash
# HTTPS with token
argocd repo add https://github.com/user/repo \
  --username git \
  --password <github-token>

# SSH
argocd repo add git@github.com:user/repo.git \
  --ssh-private-key-path ~/.ssh/id_rsa

# With custom TLS certificate
argocd repo add https://git.company.com/repo \
  --tlsClientCertPath /path/to/cert.pem \
  --tlsClientKeyPath /path/to/key.pem
```

### List Repositories
```bash
argocd repo list
```

### Remove Repository
```bash
argocd repo rm https://github.com/user/repo
```

### Test Repository Connection
```bash
argocd repo get https://github.com/user/repo
```

---

## Application Management

### Create Application
```bash
# Create from command line
argocd app create my-app \
  --repo https://github.com/user/repo \
  --path manifests \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default

# With Kustomize
argocd app create my-app-kustomize \
  --repo https://github.com/user/repo \
  --path overlays/prod \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace production

# With Helm
argocd app create my-app-helm \
  --repo https://charts.example.com \
  --chart myapp \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default

# Create from manifest file
argocd app create -f app-manifest.yaml
```

### List Applications
```bash
# All applications
argocd app list

# Watch for changes
argocd app list --watch

# JSON output
argocd app list -o json
```

### Get Application Details
```bash
# Basic info
argocd app get my-app

# Detailed YAML
argocd app get my-app -o yaml

# JSON format
argocd app get my-app -o json
```

### View Application Resources
```bash
# List all resources
argocd app resources my-app

# Show tree view
argocd app resources my-app --tree
```

### Check Application Diff
```bash
# Show differences between Git and cluster
argocd app diff my-app

# Show diff for specific resource
argocd app diff my-app --resource apps:Deployment:my-app
```

---

## Synchronization

### Manual Sync
```bash
# Sync application
argocd app sync my-app

# Sync and wait for completion
argocd app sync my-app --wait

# Force sync (ignore cache)
argocd app sync my-app --force

# Sync specific resource
argocd app sync my-app --resource Deployment:my-app
```

### Enable Auto-Sync
```bash
# Enable automated sync
argocd app set my-app --sync-policy automated

# Enable auto-prune (delete resources not in Git)
argocd app set my-app --auto-prune

# Enable self-heal (auto-fix drift)
argocd app set my-app --self-heal
```

### Disable Auto-Sync
```bash
argocd app set my-app --sync-policy none
```

### Check Sync Status
```bash
# Get sync status
argocd app get my-app | grep -A 5 "Sync Status"

# Watch sync status
argocd app wait my-app --timeout 300

# Get full status
argocd app get my-app -o yaml | grep -A 20 status:
```

---

## Application Updates

### Update Repository
```bash
argocd app set my-app --repo https://github.com/newrepo/repo
```

### Update Path
```bash
argocd app set my-app --path overlays/prod
```

### Update Namespace
```bash
argocd app set my-app --dest-namespace production
```

### Update Deployment Server
```bash
argocd app set my-app --dest-server https://other-cluster-server:6443
```

### Update Sync Policy
```bash
argocd app set my-app --sync-policy automatic --auto-prune --self-heal
```

### Patch Application
```bash
# Using JSON patch
argocd app patch my-app --type json \
  -p '[{"op":"replace","path":"/spec/source/path","value":"new/path"}]'

# Merge with YAML
argocd app patch my-app --type merge --patch '{"spec": {"source": {"path": "new/path"}}}'
```

---

## Application Deletion

### Delete Application
```bash
# Delete application (keep resources on cluster)
argocd app delete my-app

# Delete application and all associated resources
argocd app delete my-app --cascade

# Delete without confirmation
argocd app delete my-app -y
```

---

## Project Management

### List Projects
```bash
argocd proj list
```

### Create Project
```bash
argocd proj create my-project \
  --description "My project" \
  --dest https://kubernetes.default.svc,*

# Restrict to specific namespaces
argocd proj set my-project -d https://kubernetes.default.svc,specific-ns

# Allow specific Git sources
argocd proj set my-project --add-source https://github.com/myorg/repo
```

### Get Project Details
```bash
argocd proj get default
```

---

## Account & Access Control

### Change Password
```bash
argocd account update-password \
  --account admin \
  --current-password <old-password> \
  --new-password <new-password>
```

### List Accounts
```bash
argocd account list
```

### Create Local User
```bash
argocd account create-token \
  --account my-user
```

### Generate Token for Account
```bash
argocd account generate-token \
  --account admin \
  --expires-in 24h
```

---

## Cluster Management

### Add Cluster
```bash
# Add local cluster
argocd cluster add docker-desktop

# Add remote cluster
argocd cluster add my-cluster \
  --server https://cluster-server:6443 \
  --name my-cluster
```

### List Clusters
```bash
argocd cluster list
```

### Remove Cluster
```bash
argocd cluster rm https://cluster-server:6443
```

---

## Notifications & Webhooks

### Configure Webhook (GitHub)
```bash
# 1. Get webhook URL from ArgoCD
# 2. Go to GitHub repo → Settings → Webhooks
# 3. Add webhook with URL: https://argocd.example.com/api/webhook
# 4. Events: Just push
```

### List Webhooks
```bash
argocd repo get https://github.com/user/repo
```

---

## Troubleshooting Commands

### Check Health
```bash
# Application health
argocd app get my-app | grep -A 2 "Health Status"

# Cluster connectivity
argocd cluster get https://kubernetes.default.svc
```

### View Logs
```bash
# ArgoCD server logs
kubectl logs -n argocd svc/argocd-server

# ArgoCD repo server logs
kubectl logs -n argocd svc/argocd-repo-server

# ArgoCD application controller logs
kubectl logs -n argocd svc/argocd-application-controller
```

### Debug Application
```bash
# Detailed status
argocd app get my-app --refresh

# Compare Git vs Cluster
argocd app diff my-app

# Get events
argocd app events my-app

# Get logs from controller
argocd app logs my-app
```

### Force Reconciliation
```bash
# Force refresh application
argocd app get my-app --refresh

# Refresh and sync
argocd app sync my-app --force
```

---

## Useful Aliases

```bash
# Add to ~/.bashrc or ~/.zshrc
alias argocd-health='argocd app get'
alias argocd-diff='argocd app diff'
alias argocd-sync-all='argocd app list -o json | jq -r ".items[].metadata.name" | xargs -I {} argocd app sync {}'
alias argocd-list-outofync='argocd app list | grep OutOfSync'

# Watch all applications
function argocd-watch {
  watch -n 5 'argocd app list'
}

# Sync application and wait
function argocd-sync-wait {
  argocd app sync $1 && argocd app wait $1 --timeout 300
}
```

---

## Common Workflows

### Deploy a New Application
```bash
# 1. Add repository
argocd repo add https://github.com/user/repo \
  --username git \
  --password <token>

# 2. Create application
argocd app create my-app \
  --repo https://github.com/user/repo \
  --path manifests \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default

# 3. Enable auto-sync
argocd app set my-app --sync-policy automated --auto-prune

# 4. Verify
argocd app get my-app
```

### Update an Application
```bash
# 1. Update manifests in Git
git add .
git commit -m "Update app to v2.0"
git push

# 2. Wait for ArgoCD to detect (polling or webhook)
argocd app wait my-app --timeout 60

# 3. Verify sync
argocd app get my-app | grep "Sync Status"
```

### Rollback an Application
```bash
# 1. Get deployment history
argocd app history my-app

# 2. Rollback to previous commit
argocd app rollback my-app 1

# Or manually:
# 1. Revert Git commit
git revert <commit-hash>
git push

# 2. ArgoCD syncs automatically
```

### Promote Between Environments
```bash
# 1. Manually update prod manifests OR
# 2. Use GitOps flow:
git checkout -b promote/dev-to-prod
# Update overlays/prod with values from overlays/dev
git add overlays/prod
git commit -m "Promote dev changes to prod"
git push

# 3. Create PR for review
# 4. Approve and merge
# 5. ArgoCD syncs production automatically
```

---

## Tips & Tricks

### Use JSON for Scripting
```bash
# Get all app names
argocd app list -o json | jq '.items[].metadata.name'

# Get all OutOfSync apps
argocd app list -o json | jq '.items[] | select(.status.sync.status == "OutOfSync") | .metadata.name'

# Sync all apps
argocd app list -o json | jq -r '.items[].metadata.name' | xargs -I {} argocd app sync {}
```

### Watch Applications
```bash
# Watch in real-time
watch -n 5 'argocd app list'

# Or use kubectl
kubectl get applications -n argocd -w
```

### Export Application
```bash
# Export for backup
argocd app get my-app -o yaml > my-app-backup.yaml

# Restore
argocd app create -f my-app-backup.yaml
```

---

## Common Errors & Solutions

| Error | Solution |
|-------|----------|
| `Unable to connect to repository` | Check SSH keys or HTTPS credentials |
| `Application is OutOfSync` | Run `argocd app sync my-app` |
| `Pod is stuck in Pending` | Check resource requests, node availability |
| `Webhook not triggering` | Verify webhook URL and GitHub settings |
| `Cannot add cluster` | Ensure RBAC permissions for service account |

---

## Reference Links

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [ArgoCD CLI Docs](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd/)
- [GitHub Webhook Guide](https://docs.github.com/en/developers/webhooks-and-events/webhooks/creating-webhooks)
