# GitHub Actions + Docker Registry Pipeline

## 📋 Description
Un projet complet de CI/CD avec **GitHub Actions** qui automatise le build, les tests et le push d'une image Docker dans un registry. Simule un workflow de déploiement réaliste avec validation et sécurité.

## 🎯 Objectif
- Configurer un pipeline CI/CD automatisé avec GitHub Actions
- Build une image Docker et la tester
- Push l'image vers un registre Docker (simulation)
- Utiliser les secrets GitHub pour les credentials
- Implémenter des checks et validations avant le déploiement

## 🛠️ Technologies utilisées
- **GitHub Actions** - Orchestration CI/CD
- **Docker** - Containerization
- **Python Flask** - Application simple
- **Pytest** - Tests unitaires
- **Docker Compose** - Local testing

## 📋 Pré-requis
- Git et GitHub
- Docker et Docker Compose installés localement
- Un compte Docker Hub ou autre registry (optionnel pour tester en local)

## 🚀 Étapes de réalisation

### 1. Structure du projet
```
2026-06-08_github-actions-docker-registry/
├── .github/workflows/
│   ├── build.yml           # Pipeline CI/CD principal
│   ├── security-scan.yml   # Scan de sécurité
│   └── deploy.yml          # Déploiement
├── app/
│   ├── Dockerfile          # Image Docker
│   ├── app.py              # App Flask
│   ├── requirements.txt     # Dépendances
│   └── wsgi.py             # Entry point production
├── tests/
│   ├── test_app.py         # Tests unitaires
│   └── conftest.py         # Fixtures pytest
├── docker-compose.yml      # Local development
└── README.md
```

### 2. Workflow GitHub Actions
- **Build**: Compile l'image Docker
- **Test**: Lance les tests unitaires dans le conteneur
- **Push**: Push vers le registre (avec authentification)
- **Notification**: Résumé du build

### 3. Sécurité
- Utilisation de secrets GitHub pour les credentials
- Variables d'environnement sensibles
- Scan des dépendances
- Version des images avec tags git

### 4. Local testing
- Docker Compose pour tester en local
- Scripts de test rapides
- Simulation du pipeline

## 📚 Ce qu'on apprend
✅ Configurer les GitHub Actions workflows  
✅ Utiliser les secrets et variables d'environnement  
✅ Build et tester des images Docker en CI/CD  
✅ Tagging et versioning d'images  
✅ Matrix builds pour tester sur plusieurs versions Python  
✅ Notifications et logs dans les actions  
✅ Bonnes pratiques de CI/CD Docker  

## 🧪 Quick Start

### Local testing
```bash
cd projects/2026-06-08_github-actions-docker-registry

# Build l'image localement
docker build -t flask-app:local app/

# Test avec Docker Compose
docker-compose up -d
docker-compose exec web python -m pytest tests/

# Stop
docker-compose down
```

### Simuler le pipeline localement
```bash
# Run tests
docker run --rm flask-app:local python -m pytest tests/ -v

# Check image
docker inspect flask-app:local
```

## 🔑 Variables GitHub à configurer
Pour un vrai déploiement, ajouter à Settings > Secrets and variables > Actions:
- `DOCKER_USERNAME`: Username Docker Hub
- `DOCKER_PASSWORD`: Token Docker Hub
- `REGISTRY_URL`: Registry endpoint (ex: docker.io)

## 📈 Améliorations possibles
- Ajouter un scan de sécurité (Trivy)
- Implémenter le versioning sémantique
- Ajouter une notification Slack
- Intégrer Sonarqube pour la qualité du code
- Deploy sur Kubernetes ou Docker Swarm

## ✨ Commandes utiles
```bash
# Vérifier la syntaxe YAML des workflows
yamllint .github/workflows/

# Tester localement avec act (simulation GitHub Actions)
act push

# Voir les logs du workflow
gh run view <run-id> --log
```

---
**Date**: 2026-06-08  
**Niveau**: Débutant/Intermédiaire  
**Durée**: ~1-2 heures  
