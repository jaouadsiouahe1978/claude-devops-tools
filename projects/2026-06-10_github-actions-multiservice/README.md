# GitHub Actions - Pipeline CI/CD Multiservices

## 📋 Description
Pipeline CI/CD complet avec GitHub Actions pour un projet multiservices (API Python + Web Node.js).
Le pipeline inclut :
- Tests unitaires automatiques
- Analyse de code statique (linting)
- Build et push Docker multi-stages
- Déploiement automatisé
- Notifications Slack/Discord

**Objectif** : Apprendre à construire un workflow de production avec tests, build containerisé et déploiement automatisé.

## 🎯 Ce qu'on apprend
- ✅ Créer et structurer des workflows GitHub Actions
- ✅ Utiliser les matrices pour tester plusieurs versions
- ✅ Implémenter des étapes conditionnelles et des dépendances entre jobs
- ✅ Builder et pousser des images Docker vers un registre
- ✅ Gérer les secrets et variables d'environnement
- ✅ Déclencher des pipelines sur événements Git (push, PR, tags)
- ✅ Implémenter du caching pour accélérer les builds
- ✅ Publier des artifacts et des rapports

## 📦 Pré-requis
- Git et GitHub (repo public ou privé)
- Docker Hub ou GitHub Container Registry (pour les images)
- Accès aux secrets GitHub (optionnel pour les notifications)
- Connaissance basique de GitHub

## 🚀 Structure du projet

```
2026-06-10_github-actions-multiservice/
├── .github/
│   └── workflows/
│       ├── ci.yml                 # Pipeline CI principal
│       ├── docker-build.yml       # Build et push Docker
│       └── scheduled-scan.yml     # Scan de sécurité planifié
├── src/
│   ├── api.py                     # Simple API Flask
│   └── app.js                     # Simple app Node.js
├── tests/
│   ├── test_api.py               # Tests Python
│   └── test_app.js               # Tests Node.js
├── .dockerignore                  # Ignore les fichiers inutiles
├── Dockerfile.api                 # Multi-stage Dockerfile API
├── Dockerfile.web                 # Multi-stage Dockerfile Web
└── docker-compose.yml             # Local dev stack
```

## ⚙️ Étapes de réalisation

### 1️⃣ Configurer le repo GitHub
- Forker ou cloner ce projet
- Aller dans **Settings → Secrets and variables → Actions**
- Ajouter les secrets (optionnel) :
  - `DOCKER_USERNAME` : Username Docker Hub
  - `DOCKER_PASSWORD` : Token Docker Hub
  - `SLACK_WEBHOOK` : Webhook Slack (optionnel)

### 2️⃣ Comprendre les workflows
- **ci.yml** : Lance les tests à chaque push/PR
- **docker-build.yml** : Build et push images Docker
- **scheduled-scan.yml** : Scan quotidien de sécurité

### 3️⃣ Tester localement
```bash
# Tester l'API
python3 -m pytest tests/test_api.py -v

# Tester l'app Node
npm test

# Builder les images Docker
docker build -f Dockerfile.api -t api:local .
docker build -f Dockerfile.web -t web:local .

# Lancer avec docker-compose
docker-compose up
```

### 4️⃣ Déclencher les workflows
```bash
# Pusher sur main ou une branche feature
git push origin feature/new-feature

# Créer une PR → les workflows s'exécutent automatiquement

# Tagger une release
git tag v1.0.0 && git push origin v1.0.0
```

### 5️⃣ Monitorer les exécutions
- Aller dans **Actions** sur GitHub
- Voir les logs de chaque job
- Analyser les artifacts
- Vérifier les déploiements

## 📊 Points clés des workflows

### ci.yml
- Déclenché sur : push/PR vers main, push tag v*
- Matrice : teste Python 3.9, 3.10, 3.11 + Node 18, 20
- Cache dépendances pour speedup
- Upload coverage reports comme artifacts
- Badge d'état

### docker-build.yml
- Build multi-stage pour réduire la taille
- Push vers Docker Hub/GHCR
- Utilise QEMU pour ARM64
- Cache des couches Docker
- Notification Slack optionnelle

### scheduled-scan.yml
- Scan Trivy (sécurité image)
- Exécuté quotidiennement
- Upload rapports SARIF

## 🔧 Customization

```bash
# Changer le registre Docker
# Éditer docker-build.yml : DOCKER_REGISTRY

# Ajouter une notification Slack
# Décommenter la step "Notify Slack"

# Ajouter des tests de performance
# Créer tests/benchmark.py

# Déclencher sur plus d'événements
# Éditer .github/workflows/*.yml : on:
```

## 🎓 Commandes à essayer

```bash
# Voir l'historique des workflows
gh workflow list

# Déclencher un workflow manuellement
gh workflow run ci.yml

# Voir le log en temps réel
gh run view <run-id> --log

# Télécharger les artifacts
gh run download <run-id> -n coverage-report
```

## ✨ Points DevOps importants

| Aspect | Détail |
|--------|--------|
| **Infrastructure as Code** | Workflows YML = IaC du CI/CD |
| **Automation** | Tests, build, push = 0 intervention manuelle |
| **Reliability** | Cache, retry, notifications |
| **Security** | Secrets gérés, SBOM, scans |
| **Observability** | Logs, artifacts, métriques |

## 🚨 Troubleshooting

| Problème | Solution |
|----------|----------|
| Workflow stuck | Vérifier les secrets, re-run job |
| Build échoue | Vérifier logs, tester localement |
| Push Docker échoue | Checker credentials, permissions |
| Trop lent | Augmenter cache, paralléliser jobs |

## 📚 Ressources
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Workflow syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Best practices](https://docs.github.com/en/actions/guides)
- [Security hardening](https://docs.github.com/en/actions/security-guides)

---
**Durée estimée** : 1-2 heures  
**Difficulté** : Intermédiaire  
**Prérequis** : Git, Docker, GitHub
