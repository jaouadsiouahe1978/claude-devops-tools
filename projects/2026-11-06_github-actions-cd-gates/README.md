# GitHub Actions CD avec Approval Gates

## 📋 Description

Mise en place d'un pipeline CI/CD avancé avec GitHub Actions incluant :
- Workflows multi-étapes (build → test → deploy)
- Approval gates manuels avant déploiement en production
- Gestion des environnements (dev, staging, prod)
- Gestion des secrets et tokens
- Artifacts et releases
- Matrix builds pour multi-plateforme
- Notifications et alertes de déploiement

## 🎯 Objectif Pédagogique

Apprendre à :
- Structurer des workflows GitHub Actions complexes
- Implémenter des contrôles qualité et approbation
- Gérer les secrets en sécurité
- Déployer sur plusieurs environnements
- Utiliser les environment variables et protections de branches
- Créer une vraie pipeline CI/CD d'entreprise

## 🛠️ Technologies

- **GitHub Actions** - Orchestration CI/CD
- **Docker** - Containerization et testing
- **Kubernetes** - Multi-env deployment
- **Node.js** - Application d'exemple
- **GitHub Environments** - Gestion des déploiements

## 📦 Structure du Projet

```
.github/
  workflows/
    ci.yml                 # Build et tests
    cd-staging.yml         # Deploy staging (auto)
    cd-production.yml      # Deploy prod (avec approval)
    matrix-build.yml       # Build multi-plateforme
    release.yml            # Gestion des releases
    rollback.yml           # Rollback manual
  
src/
  app.js                   # Application simple
  Dockerfile               # Image Docker
  
docs/
  DEPLOYMENT.md            # Guide de déploiement
  WORKFLOWS.md             # Explication des workflows
  SECRETS.md               # Config des secrets
  
.dockerignore
.gitignore
docker-compose.yml         # Local development
package.json               # Dependencies Node.js
```

## 📝 Étapes de Réalisation

### 1️⃣ Préparation Locale (10 min)
```bash
# Install dependencies
npm install

# Test l'app localement
docker-compose up

# Accès: http://localhost:3000
```

### 2️⃣ Configuration GitHub Actions (15 min)
- Créer 5 workflows dans `.github/workflows/`
- Définir les environnements GitHub (Settings > Environments)
  - dev (sans restrictions)
  - staging (require status checks)
  - production (avec approval gates + branch protection)

### 3️⃣ Configuration des Secrets
GitHub Settings > Secrets > Actions
```
- DOCKER_REGISTRY_USER
- DOCKER_REGISTRY_PASSWORD  
- KUBE_CONFIG_PROD
- SLACK_WEBHOOK
```

### 4️⃣ Déploiement Test
- Push sur `develop` → déclenche CI + deploy staging (auto)
- Ouvrir une PR → status checks requis
- Merger sur `main` → déclenche CI + demande approval avant prod
- Approver le deployment → déploie en production

### 5️⃣ Monitoring et Rollback
- Voir statuses dans l'onglet "Deployments"
- Utiliser le workflow rollback en cas de problème
- Recevoir les notifications Slack

## 🚀 Utilisation

### Déclencher un build local
```bash
docker build -t myapp:latest .
docker run -p 3000:3000 myapp:latest
```

### Déclencher la CI/CD
```bash
# Feature branch
git checkout -b feature/new-feature
git push origin feature/new-feature

# PR automatiquement déclenche CI
# Une fois merged sur develop → CI + auto-deploy staging
# Push sur main → CI + demande approval pour prod
```

### Approver un déploiement production
- Aller dans l'onglet "Deployments" du repo
- Cliquer sur le deployment en attente
- Approver ou rejeter le déploiement

## 📊 Concepts Clés Appris

1. **GitHub Workflows** - Automatisation avec YAML
2. **Event-driven CI/CD** - Déclencher sur push, PR, tag
3. **Environments & Protections** - Contrôles de déploiement
4. **Secrets Management** - Gestion sécurisée des credentials
5. **Status Checks** - Exiger des tests avant merge
6. **Artifacts & Caching** - Optimiser les builds
7. **Matrix Strategy** - Build multi-version/plateforme
8. **Approval Gates** - Validation humaine avant prod
9. **Notifications** - Alertes et rapports
10. **Rollback Strategy** - Récupération en cas d'erreur

## 📚 Ce qu'on Apprend Aujourd'hui

- Structure d'une vraie pipeline d'entreprise
- Best practices GitHub Actions
- Sécurité des workflows (secrets, permissions)
- Déploiement multi-environnement en production
- Intégration avec outils externes (Slack, registries)
- Gestion des versions et releases
- Rollback et disaster recovery

## 🔗 Liens Utiles

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [GitHub Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments)
- [Workflow Syntax](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions)
- [Security Best Practices](https://docs.github.com/en/actions/security-guides)

## ✅ Checklist Complétude

- [x] Workflows CI/CD configurés
- [x] Environments GitHub créés
- [x] Approval gates configurés
- [x] Secrets définis
- [x] Branch protections appliquées
- [x] Notifications configurées
- [x] Application de test incluse
- [x] Documentation complète

**Temps d'apprentissage :** 8h - **Niveau :** Intermédiaire⭐⭐⭐
