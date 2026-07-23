# Configuration des Règles de Protection de Branches

## 🛡️ Protection pour `main` (Production)

```yaml
Branch Protection Rules:
  - Require pull requests: 2 approvers
  - Require status checks: build, test, lint, security
  - Require branches up to date: true
  - Include administrators: true
  - Allow force pushes: false
  - Allow deletions: false
```

## 📝 Configuration via CLI

```bash
#!/bin/bash
OWNER="jaouadsiouahe1978"
REPO="claude-devops-tools"

# Protection pour main
gh api --method PUT \
  repos/${OWNER}/${REPO}/branches/main/protection \
  -f required_status_checks='{"strict":true,"contexts":["build","test","lint"]}' \
  -f enforce_admins=true \
  -f required_pull_request_reviews='{"required_approving_review_count":2}' \
  -f allow_force_pushes=false \
  -f allow_deletions=false
```

## 🚀 Git Workflow

```
feature branch
    ↓
    PR → Review (2 approvers) → Checks pass → Merge to main
    ↓
Production Deployment
```

## 📋 CODEOWNERS

Créer `.github/CODEOWNERS`:

```
# DevOps projects
/projects/ @jaouadsiouahe1978

# GitHub Actions workflows
.github/workflows/ @jaouadsiouahe1978

# Docker files
Dockerfile* @jaouadsiouahe1978
```

## ✅ Checklist

- [ ] main branch protection actif
- [ ] 2 approvers requis
- [ ] Status checks configurés
- [ ] CODEOWNERS créé
- [ ] Admins enforced
