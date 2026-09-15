# Quick Start Guide

## 1. Setup Local Environment

```bash
# Clone or navigate to project
cd projects/2026-09-15_github-actions-cd-pipeline

# Install Node.js dependencies
npm install

# Install linter dependencies (if not in npm install)
npm install --save-dev eslint eslint-config-airbnb-base eslint-plugin-import jest
```

## 2. Test Locally

```bash
# Run linter
npm run lint
npm run lint:fix

# Run tests
npm run test

# Run with docker-compose
docker-compose up

# Test endpoints
curl http://localhost:3000/api/health
curl http://localhost:3000/api/version
curl http://localhost:3000/api/status

# Cleanup
docker-compose down
```

## 3. GitHub Setup

### Create 3 Environments in Repository Settings

1. **Settings → Environments → New environment**
   - Create: `dev`
   - Create: `staging`
   - Create: `prod` (with required reviewers = your username)

### Add Secrets (optional, for real deployments)

For each environment, add these secrets in Settings → Environments → [env-name] → Secrets:

```
DEPLOY_HOST = your-server.com
DEPLOY_USER = deploy-user
DEPLOY_KEY = <base64-encoded SSH key>
```

## 4. Push to GitHub

```bash
git add .
git commit -m "Add GitHub Actions CI/CD pipeline"
git push origin main
```

## 5. Monitor Pipeline

1. Go to GitHub repository
2. Click **Actions** tab
3. Watch the **CI/CD Pipeline** workflow
4. When it reaches **Deploy to Production**, approve it manually

## Pipeline Flow

```
✓ Code Push
├─ Lint (ESLint) 
├─ Test (Jest)
├─ Build Docker Image
├─ Deploy to Dev ✓
├─ Deploy to Staging ✓
└─ Deploy to Production (⏳ awaiting approval)
   └─ [Manual Approval in GitHub UI]
      └─ Deploy to Production ✓
```

## Useful Commands

```bash
# View workflow status
gh workflow list

# Trigger workflow manually
gh workflow run ci-pipeline.yml

# View recent runs
gh run list

# View specific run logs
gh run view <run-id> --log

# Cancel running workflow
gh run cancel <run-id>
```

## Troubleshooting

### Tests failing locally?
```bash
npm run test:watch  # Run in watch mode to debug
```

### Linting issues?
```bash
npm run lint:fix    # Auto-fix eslint issues
```

### Docker build failing?
```bash
docker build -t app:test .   # Build locally to test
docker run -p 3000:3000 app:test  # Run to verify
```

### Can't connect to container?
```bash
docker-compose ps           # Check running services
docker-compose logs -f app  # View logs
```

## Next Steps

1. Customize deploy jobs with actual deployment commands
2. Add Slack/Discord notifications
3. Integrate security scanning (Trivy)
4. Add performance testing
5. Implement canary deployments
6. Add database migrations
7. Set up monitoring alerts
