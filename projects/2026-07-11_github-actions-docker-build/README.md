# GitHub Actions - Docker Auto-Build & Push to Registry

**Date:** 2026-07-11  
**Niveau:** Débutant à Intermédiaire  
**Durée:** 1 journée

## Objectif

Créer un **workflow CI/CD complet avec GitHub Actions** qui automatise le build et le push d'une image Docker vers Docker Hub à chaque push sur `main`.

## Technos utilisées

- **GitHub Actions** - Orchestration CI/CD native
- **Docker** - Containerization
- **Docker Hub** - Registry privée/publique
- **Node.js** - Application de démonstration

## Ce qu'on apprend

✅ Créer un workflow GitHub Actions (`.github/workflows/`)  
✅ Utiliser des actions Docker officielles (`docker/setup-buildx`, `docker/build-push`)  
✅ Gérer les secrets GitHub pour Docker Hub  
✅ Utiliser les tags de version automatiques  
✅ Implémenter le cache Docker pour accélérer les builds  
✅ Déclencher des workflows sur événements (push, pull_request, schedule)  
✅ Logger et monitorer les builds CI/CD  

## Architecture

```
app/
├── src/
│   ├── index.js          # Application Node.js simple
│   └── package.json
├── Dockerfile            # Multi-stage pour optimisation
└── .dockerignore

.github/
└── workflows/
    ├── docker-build-push.yml    # CI/CD principal
    └── docker-test.yml          # Tests avant push
```

## Étapes de réalisation

### 1. Prérequis
- Compte Docker Hub
- Compte GitHub avec ce repo
- Secrets configurés dans GitHub (DOCKER_USERNAME, DOCKER_PASSWORD)

### 2. Créer l'application Node.js
- Application web simple sur port 3000
- Endpoint health check
- Dockerfile optimisé (multi-stage)

### 3. Configurer GitHub Secrets
- `DOCKER_USERNAME` = votre username Docker Hub
- `DOCKER_PASSWORD` = votre access token Docker Hub

### 4. Créer les workflows GitHub Actions
- **docker-build-push.yml** : Build et push sur main
  - Trigger: push sur main
  - Build avec buildx (support multi-arch)
  - Tag avec version et latest
  - Push automatique vers Docker Hub
  - Cache des couches Docker

- **docker-test.yml** : Tests et build sur PR
  - Trigger: pull_request, push (branches de dev)
  - Build local seulement (pas de push)
  - Tests de base de l'image

### 5. Documenter les étapes de déploiement
- Comment configurer les secrets
- Comment utiliser l'image générée
- Logs et monitoring des builds

## Utilisation

```bash
# Configuration locale
export DOCKER_USERNAME=votre_username
export DOCKER_PASSWORD=votre_token

# Tester localement
docker build -t test-app:latest .
docker run -p 3000:3000 test-app:latest

# Push sur main déclenche le workflow
git push origin main
# → GitHub Actions construit et push vers docker.io/username/test-app:latest
```

## Prochaines étapes

- Ajouter des tests unitaires dans le workflow
- Implémenter le scanning d'images (Trivy)
- Ajouter des notifications Slack/Discord
- Secrets rotation automatique
- Matrix builds pour multi-architecture (arm64, amd64)

## Ressources

- [GitHub Actions - Workflows](https://docs.github.com/en/actions/using-workflows)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [Docker Hub](https://hub.docker.com/)
- [Best Practices - Docker Images](https://docs.docker.com/develop/dev-best-practices/)
