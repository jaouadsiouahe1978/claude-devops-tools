# GitHub Actions Workflows Documentation

## 📋 Overview

This project includes three main CI/CD workflows:

### 1. **build.yml** - Build & Test Pipeline
**Trigger**: `push` et `pull_request` sur main/develop
**Actions principales**:
- Build image Docker (multi-stage)
- Run tests en conteneur (matrix: Python 3.10, 3.11, 3.12)
- Lint code avec pylint
- Check image size
- Test endpoints HTTP
- Scan image avec Trivy
- Générer SBOM (Software Bill of Materials)

**Matrix builds**: Teste l'application sur 3 versions de Python

### 2. **security-scan.yml** - Security & Vulnerability Scanning
**Trigger**: `push`, `pull_request`, et `schedule` (hebdomadaire)
**Actions**:
- Trivy filesystem scan
- Secrets detection avec trufflesecurity
- Dependency vulnerability check
- Dockerfile linting avec hadolint

**Scheduled**: Lance automatiquement chaque dimanche à 02h UTC

### 3. **deploy.yml** - Push vers Registry
**Trigger**: Tags git (`v*`) ou `workflow_dispatch`
**Actions**:
- Build et push image
- Support des secrets Docker Hub
- SBOM et métadonnées OCI
- Notification Slack (optionnel)

## 🔐 Secrets à configurer

Dans **Settings > Secrets and variables > Actions** du repo GitHub:

```
DOCKER_USERNAME      - Docker Hub username
DOCKER_PASSWORD      - Docker Hub token/password
SLACK_WEBHOOK        - Slack webhook URL (optionnel)
```

## 🚀 Configuration initiale

### 1. Cloner le repo
```bash
cd projects/2026-06-08_github-actions-docker-registry
git init
git add -A
git commit -m "Initial commit"
git remote add origin https://github.com/jaouadsiouahe1978/claude-devops-tools.git
git push -u origin main
```

### 2. Configurer les secrets GitHub
```bash
# Depuis l'interface GitHub:
Settings > Secrets and variables > Actions > New repository secret

Ajouter:
- DOCKER_USERNAME: votre_username
- DOCKER_PASSWORD: votre_token
```

### 3. Configurer les environments (optionnel)
```bash
Settings > Environments > New environment
- staging
- production
```

## 📊 Workflow Statuses

Voir l'état des workflows:
```bash
# Voir tous les runs
gh run list

# Voir les logs d'un run spécifique
gh run view <RUN_ID> --log

# Réexécuter un workflow
gh run rerun <RUN_ID>

# Voir les artifacts
gh run view <RUN_ID> --json artifacts
```

## 🎯 Events et Triggers

### build.yml
```yaml
on:
  push:
    branches: [main, develop]
    paths: [app/**, tests/**, .github/workflows/build.yml]
  pull_request:
    branches: [main]
```

### deploy.yml
```yaml
on:
  push:
    tags: ['v*']
  workflow_dispatch:  # Manual trigger
```

## 📈 Best Practices

### 1. **Caching**
- Les layers Docker sont cachés avec GitHub Actions cache
- Accélère les builds suivants

### 2. **Matrix Builds**
- Teste sur 3 versions de Python
- Détecte les incompatibilités rapidement

### 3. **Security**
- Trivy scan des images
- Trufflesecurity pour les secrets
- Hadolint pour les Dockerfiles

### 4. **Artifacts**
- SBOM généré pour chaque build
- Peut être utilisé pour l'audit de sécurité

## 🔄 Debugging

### Vérifier la syntaxe YAML
```bash
yamllint .github/workflows/
```

### Tester localement avec `act`
```bash
# Installer act (macOS/Linux)
brew install act
# ou
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | bash

# Simuler le workflow
act push -j build
act pull_request -j build
```

### Voir les logs détaillés
```bash
gh run view <RUN_ID> --log
```

### Re-run un workflow qui a échoué
```bash
gh run rerun <RUN_ID>
```

## 💡 Tips & Tricks

### Forcer un rebuild sans push
```bash
git commit --allow-empty -m "Rebuild trigger"
git push
```

### Tagguer une release
```bash
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0
# → Automatiquement déclenche deploy.yml
```

### Vérifier les dépendances Python
```bash
docker run --rm -v $(pwd):/app python:3.11-slim \
  sh -c "cd /app && pip install -r app/requirements.txt && pip list"
```

### Analyser la taille de l'image
```bash
docker build -t flask-app:latest app/
docker inspect -f='{{json .Size}}' flask-app:latest | jq '. / 1024 / 1024'
```

## 🚨 Troubleshooting

### Build échoue: "No such file or directory"
**Cause**: Mauvais contexte Docker
**Fix**: Vérifier les `paths` dans le `on.push` du workflow

### Tests échouent dans le conteneur
**Cause**: Dépendances manquantes
**Fix**: Vérifier `requirements.txt` inclut pytest

### Image trop grosse
**Cause**: Multi-stage Dockerfile non optimisé
**Fix**: Nettoyer les fichiers temporaires en fin de build

### Push vers registry échoue
**Cause**: Secrets mal configurés
**Fix**: Vérifier `DOCKER_USERNAME` et `DOCKER_PASSWORD` dans Settings

## 📚 Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [Trivy Scanner](https://github.com/aquasecurity/trivy-action)
- [act - Local workflow testing](https://github.com/nektos/act)
- [Hadolint - Dockerfile linter](https://github.com/hadolint/hadolint-action)
